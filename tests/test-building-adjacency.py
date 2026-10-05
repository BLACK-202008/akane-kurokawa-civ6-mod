"""Execute gameplay SQL and check its building-bonus attachment contract.

Requires a Civ6 Gathering Storm DebugGameplay.sqlite (override the default with
CIV6_GAMEPLAY_DATABASE). The source is opened read-only and copied to memory.
The small graph evaluator below checks collection/requirement object boundaries
with controlled cities and districts; it is not the Civ6 runtime. Make_Hash is
stubbed solely for native Type-insertion triggers, never used in assertions.
"""

from collections import Counter
import os
from pathlib import Path
import sqlite3
import unittest
import xml.etree.ElementTree as ET
import zlib


ROOT = Path(__file__).resolve().parents[1]
DATABASE = Path(os.environ.get("CIV6_GAMEPLAY_DATABASE", str(
    Path.home() / "AppData/Local/Firaxis Games/Sid Meier's Civilization VI/Cache/DebugGameplay.sqlite"
)))
TARGETS = [
    ("LIBRARY", "BUILDING_LIBRARY", "YIELD_SCIENCE"),
    ("UNIVERSITY", "BUILDING_UNIVERSITY", "YIELD_SCIENCE"),
    ("RESEARCH_LAB", "BUILDING_RESEARCH_LAB", "YIELD_SCIENCE"),
    ("MARKET", "BUILDING_MARKET", "YIELD_GOLD"),
    ("BANK", "BUILDING_BANK", "YIELD_GOLD"),
    ("STOCK_EXCHANGE", "BUILDING_STOCK_EXCHANGE", "YIELD_GOLD"),
    ("LIGHTHOUSE_GOLD", "BUILDING_LIGHTHOUSE", "YIELD_GOLD"),
    ("LIGHTHOUSE_FOOD", "BUILDING_LIGHTHOUSE", "YIELD_FOOD"),
    ("SHIPYARD", "BUILDING_SHIPYARD", "YIELD_PRODUCTION"),
    ("SEAPORT_GOLD", "BUILDING_SEAPORT", "YIELD_GOLD"),
    ("SEAPORT_FOOD", "BUILDING_SEAPORT", "YIELD_FOOD"),
    ("BARRACKS", "BUILDING_BARRACKS", "YIELD_PRODUCTION"),
    ("STABLE", "BUILDING_STABLE", "YIELD_PRODUCTION"),
    ("ARMORY", "BUILDING_ARMORY", "YIELD_PRODUCTION"),
    ("MILITARY_ACADEMY", "BUILDING_MILITARY_ACADEMY", "YIELD_PRODUCTION"),
    ("WORKSHOP", "BUILDING_WORKSHOP", "YIELD_PRODUCTION"),
    ("FACTORY", "BUILDING_FACTORY", "YIELD_PRODUCTION"),
    ("ELECTRONICS_FACTORY", "BUILDING_ELECTRONICS_FACTORY", "YIELD_PRODUCTION"),
    ("COAL_POWER_PLANT", "BUILDING_COAL_POWER_PLANT", "YIELD_PRODUCTION"),
    ("FOSSIL_FUEL_POWER_PLANT", "BUILDING_FOSSIL_FUEL_POWER_PLANT", "YIELD_PRODUCTION"),
    ("POWER_PLANT", "BUILDING_POWER_PLANT", "YIELD_PRODUCTION"),
    ("SHRINE", "BUILDING_SHRINE", "YIELD_FAITH"),
    ("TEMPLE", "BUILDING_TEMPLE", "YIELD_FAITH"),
]


def load_xml(connection, path):
    for table in ET.parse(path).getroot():
        types = {row[1]: row[2].upper() for row in connection.execute(
            f'PRAGMA table_info("{table.tag}")'
        )}
        for node in table:
            if node.tag != "Row":
                raise ValueError(f"Unsupported operation {node.tag}: {path}")
            values = dict(node.attrib)
            values.update({child.tag: child.text for child in node})
            for key, value in values.items():
                if types.get(key) == "BOOLEAN" and value.lower() in ("true", "false"):
                    values[key] = int(value.lower() == "true")
            columns = ",".join(f'"{key}"' for key in values)
            connection.execute(
                f'INSERT INTO "{table.tag}" ({columns}) VALUES ({",".join("?" for _ in values)})',
                list(values.values()),
            )


def load_database():
    native = sqlite3.connect(DATABASE.resolve().as_uri() + "?mode=ro", uri=True)
    connection = sqlite3.connect(":memory:")
    native.backup(connection)
    native.close()
    connection.row_factory = sqlite3.Row
    connection.create_function("Make_Hash", 1, lambda text: zlib.crc32(text.encode()) if text else 0)
    baseline = set(map(tuple, connection.execute("PRAGMA foreign_key_check")))
    manifest = ET.parse(next(ROOT.glob("*.modinfo"))).getroot()
    for action in manifest.find("InGameActions"):
        if action.tag != "UpdateDatabase":
            continue
        for node in action.findall("File"):
            path = ROOT / node.text
            if path.suffix == ".sql":
                connection.executescript(path.read_text(encoding="utf-8-sig"))
            else:
                load_xml(connection, path)
    violations = set(map(tuple, connection.execute("PRAGMA foreign_key_check"))) - baseline
    if violations:
        raise AssertionError(f"New database foreign-key violations: {violations}")
    return connection


class BuildingGraph:
    """Evaluate the native collection contract, with exact BuildingType targets."""

    def __init__(self, database):
        self.database = database

    def modifier(self, modifier_id):
        row = self.database.execute("""
            SELECT m.*,d.CollectionType,d.EffectType FROM Modifiers m
            JOIN DynamicModifiers d USING (ModifierType) WHERE ModifierId=?
        """, (modifier_id,)).fetchone()
        if row is None:
            raise AssertionError(f"Undefined modifier/type: {modifier_id}")
        args = dict(self.database.execute(
            "SELECT Name,Value FROM ModifierArguments WHERE ModifierId=?", (modifier_id,)
        ))
        return row, args

    def paths(self, modifier_id, path=()):
        row, args = self.modifier(modifier_id)
        path = (*path, row)
        if row["EffectType"] == "EFFECT_ADJUST_BUILDING_YIELD_MODIFIER":
            return [path]
        if row["EffectType"] == "EFFECT_ATTACH_MODIFIER":
            return self.paths(args["ModifierId"], path)
        return []

    def roots(self):
        ids = [row[0] for row in self.database.execute(
            "SELECT ModifierId FROM TraitModifiers WHERE TraitType='TRAIT_CIVILIZATION_LALALAI'"
        )]
        return [modifier_id for modifier_id in ids if self.paths(modifier_id)]

    def requirement_set(self, set_id, subject):
        if set_id is None:
            return True
        set_type = self.database.execute(
            "SELECT RequirementSetType FROM RequirementSets WHERE RequirementSetId=?", (set_id,)
        ).fetchone()[0]
        answers = []
        for row in self.database.execute("""
            SELECT r.* FROM RequirementSetRequirements rsr
            JOIN Requirements r USING (RequirementId) WHERE RequirementSetId=?
        """, (set_id,)):
            args = dict(self.database.execute(
                "SELECT Name,Value FROM RequirementArguments WHERE RequirementId=?", (row["RequirementId"],)
            ))
            requirement_type = row["RequirementType"]
            if requirement_type == "REQUIREMENT_REQUIREMENTSET_IS_MET":
                matches = self.requirement_set(args["RequirementSetId"], subject)
            elif requirement_type == "REQUIREMENT_CITY_HAS_DISTRICT":
                matches = subject["kind"] == "city" and any(
                    district["type"] == args["DistrictType"] for district in subject["districts"]
                )
            elif requirement_type == "REQUIREMENT_CITY_HAS_BUILDING":
                matches = subject["kind"] == "city" and args["BuildingType"] in subject["buildings"]
            elif requirement_type == "REQUIREMENT_DISTRICT_TYPE_MATCHES":
                matches = subject["kind"] == "district" and subject["type"] == args["DistrictType"]
            elif requirement_type == "REQUIREMENT_PLOT_ADJACENT_DISTRICT_TYPE_MATCHES":
                if subject["kind"] != "district":
                    raise AssertionError("Plot adjacency requirement evaluated on a non-district object")
                matches = args["DistrictType"] in subject["adjacent_types"]
            else:
                raise AssertionError(f"Unsupported building-chain requirement: {requirement_type}")
            answers.append(not matches if row["Inverse"] else matches)
        return any(answers) if set_type == "REQUIREMENTSET_TEST_ANY" else all(answers)

    def grants(self, cities):
        player = {"kind": "player", "cities": cities}
        totals, subject_stacks = Counter(), Counter()

        def attach(modifier_id, owner):
            row, args = self.modifier(modifier_id)
            if not self.requirement_set(row["OwnerRequirementSetId"], owner):
                return
            collection = row["CollectionType"]
            if collection == "COLLECTION_PLAYER_CITIES":
                subjects = cities
            elif collection == "COLLECTION_CITY_DISTRICTS":
                if owner["kind"] != "city":
                    raise AssertionError("City district collection has a non-city owner")
                subjects = owner["districts"]
            elif collection == "COLLECTION_OWNER_CITY":
                if owner["kind"] != "district":
                    raise AssertionError("Building payload must be owned by a selected district")
                subjects = [owner["city"]]
            else:
                raise AssertionError(f"Unexpected building-chain collection: {collection}")
            for subject in subjects:
                if not self.requirement_set(row["SubjectRequirementSetId"], subject):
                    continue
                if row["EffectType"] == "EFFECT_ATTACH_MODIFIER":
                    attach(args["ModifierId"], subject)
                else:
                    if subject["kind"] != "city":
                        raise AssertionError("Building yield effect applied to a non-city")
                    stack_key = (modifier_id, subject["id"])
                    limit = row["SubjectStackLimit"]
                    if limit is not None and subject_stacks[stack_key] >= limit:
                        continue
                    subject_stacks[stack_key] += 1
                    if args["BuildingType"] in subject["buildings"]:
                        totals[(subject["id"], args["BuildingType"], args["YieldType"])] += int(args["Amount"])

        for root in self.roots():
            attach(root, player)
        return totals


def city(city_id, district_type="DISTRICT_CAMPUS", adjacent=False, buildings=("BUILDING_LIBRARY",)):
    result = {"kind": "city", "id": city_id, "buildings": set(buildings), "districts": []}
    result["districts"] = [
        {"kind": "district", "city": result, "type": district_type,
         "adjacent_types": {"DISTRICT_LALALAI_TROUPE"} if adjacent else set()},
        {"kind": "district", "city": result, "type": "DISTRICT_LALALAI_TROUPE", "adjacent_types": set()},
    ]
    return result


class BuildingAdjacencyTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.database = load_database()
        cls.graph = BuildingGraph(cls.database)

    @classmethod
    def tearDownClass(cls):
        cls.database.close()

    def test_nonadjacent_campus_does_not_boost_its_library(self):
        self.assertEqual(self.graph.grants([city("a")])[("a", "BUILDING_LIBRARY", "YIELD_SCIENCE")], 0)

    def test_adjacent_campus_boost_does_not_flow_to_other_cities(self):
        grants = self.graph.grants([city("a", adjacent=True), city("b")])
        self.assertEqual(grants[("a", "BUILDING_LIBRARY", "YIELD_SCIENCE")], 50)
        self.assertEqual(grants[("b", "BUILDING_LIBRARY", "YIELD_SCIENCE")], 0)

    def test_captured_seowon_is_a_valid_adjacent_campus(self):
        grants = self.graph.grants([city("captured", "DISTRICT_SEOWON", True)])
        self.assertEqual(grants[("captured", "BUILDING_LIBRARY", "YIELD_SCIENCE")], 50)

    def test_all_six_building_chains_use_their_corresponding_adjacent_district(self):
        chains = [
            ("DISTRICT_CAMPUS", [
                ("BUILDING_LIBRARY", "YIELD_SCIENCE"), ("BUILDING_UNIVERSITY", "YIELD_SCIENCE"),
                ("BUILDING_RESEARCH_LAB", "YIELD_SCIENCE"),
            ]),
            ("DISTRICT_COMMERCIAL_HUB", [
                ("BUILDING_MARKET", "YIELD_GOLD"), ("BUILDING_BANK", "YIELD_GOLD"),
                ("BUILDING_STOCK_EXCHANGE", "YIELD_GOLD"),
            ]),
            ("DISTRICT_HARBOR", [
                ("BUILDING_LIGHTHOUSE", "YIELD_GOLD"), ("BUILDING_LIGHTHOUSE", "YIELD_FOOD"),
                ("BUILDING_SHIPYARD", "YIELD_PRODUCTION"), ("BUILDING_SEAPORT", "YIELD_GOLD"),
                ("BUILDING_SEAPORT", "YIELD_FOOD"),
            ]),
            ("DISTRICT_ENCAMPMENT", [
                ("BUILDING_BARRACKS", "YIELD_PRODUCTION"), ("BUILDING_STABLE", "YIELD_PRODUCTION"),
                ("BUILDING_ARMORY", "YIELD_PRODUCTION"), ("BUILDING_MILITARY_ACADEMY", "YIELD_PRODUCTION"),
            ]),
            ("DISTRICT_INDUSTRIAL_ZONE", [
                ("BUILDING_WORKSHOP", "YIELD_PRODUCTION"), ("BUILDING_FACTORY", "YIELD_PRODUCTION"),
                ("BUILDING_ELECTRONICS_FACTORY", "YIELD_PRODUCTION"), ("BUILDING_COAL_POWER_PLANT", "YIELD_PRODUCTION"),
                ("BUILDING_FOSSIL_FUEL_POWER_PLANT", "YIELD_PRODUCTION"), ("BUILDING_POWER_PLANT", "YIELD_PRODUCTION"),
            ]),
            ("DISTRICT_HOLY_SITE", [("BUILDING_SHRINE", "YIELD_FAITH"), ("BUILDING_TEMPLE", "YIELD_FAITH")]),
        ]
        for district_type, pairs in chains:
            with self.subTest(district_type=district_type):
                buildings = [building for building, _ in pairs]
                grants = self.graph.grants([
                    city("adjacent", district_type, True, buildings),
                    city("disconnected", district_type, False, buildings),
                ])
                for building, yield_type in pairs:
                    self.assertEqual(grants[("adjacent", building, yield_type)], 50)
                    self.assertEqual(grants[("disconnected", building, yield_type)], 0)

    def test_neighbor_citys_troupe_does_not_remove_the_own_city_gate(self):
        no_troupe = city("a", adjacent=True)
        no_troupe["districts"] = no_troupe["districts"][:1]
        grants = self.graph.grants([no_troupe, city("b")])
        self.assertEqual(grants[("a", "BUILDING_LIBRARY", "YIELD_SCIENCE")], 0)

    def test_replacement_building_families_keep_their_existing_yield_targets(self):
        # Preserve the native BuildingType/BuildingReplaces contract. This test
        # does not invent or claim to execute the engine's replacement lookup.
        targets = {
            (self.graph.modifier(path[-1]["ModifierId"])[1]["BuildingType"],
             self.graph.modifier(path[-1]["ModifierId"])[1]["YieldType"])
            for root in self.graph.roots() for path in self.graph.paths(root)
        }
        cases = [
            ("BUILDING_MADRASA", "BUILDING_UNIVERSITY", "YIELD_SCIENCE"),
            ("BUILDING_STAVE_CHURCH", "BUILDING_TEMPLE", "YIELD_FAITH"),
            ("BUILDING_SUKIENNICE", "BUILDING_MARKET", "YIELD_GOLD"),
            ("BUILDING_BASILIKOI_PAIDES", "BUILDING_BARRACKS", "YIELD_PRODUCTION"),
            ("BUILDING_ELECTRONICS_FACTORY", "BUILDING_FACTORY", "YIELD_PRODUCTION"),
        ]
        for building, base_building, yield_type in cases:
            with self.subTest(building=building):
                native_base = self.database.execute(
                    "SELECT ReplacesBuildingType FROM BuildingReplaces WHERE CivUniqueBuildingType=?",
                    (building,),
                ).fetchone()[0]
                self.assertEqual(native_base, base_building)
                self.assertIn((base_building, yield_type), targets)

    def test_matching_districts_in_one_city_cannot_stack_the_same_building_bonus(self):
        duplicate = city("a", adjacent=True)
        duplicate["districts"].append({
            "kind": "district", "city": duplicate, "type": "DISTRICT_SEOWON",
            "adjacent_types": {"DISTRICT_LALALAI_TROUPE"},
        })
        grants = self.graph.grants([duplicate, city("b", adjacent=True)])
        self.assertEqual(grants[("a", "BUILDING_LIBRARY", "YIELD_SCIENCE")], 50)
        self.assertEqual(grants[("b", "BUILDING_LIBRARY", "YIELD_SCIENCE")], 50)

    def test_building_payload_uses_selected_districts_owner_city(self):
        for root in self.graph.roots():
            for path in self.graph.paths(root):
                with self.subTest(root=root):
                    self.assertEqual([row["CollectionType"] for row in path], [
                        "COLLECTION_PLAYER_CITIES", "COLLECTION_CITY_DISTRICTS", "COLLECTION_OWNER_CITY",
                    ])
                    self.assertIsNone(path[-1]["OwnerRequirementSetId"])
                    self.assertIsNone(path[-1]["SubjectRequirementSetId"])
                    self.assertEqual(path[-1]["SubjectStackLimit"], 1)
                    for modifier in path:
                        self.assertEqual(modifier["Permanent"], 0,
                                         "Adjacency-dependent attachments must be removable")

    def test_all_original_building_yield_pairs_remain_reachable(self):
        reachable = {
            path[-1]["ModifierId"]
            for root in self.graph.roots() for path in self.graph.paths(root)
        }
        for stem, building, yield_type in TARGETS:
            modifier_id = f"AKANE_BUILDING_{stem}_FROM_LALALAI"
            with self.subTest(modifier_id=modifier_id):
                self.assertIn(modifier_id, reachable)
                _, args = self.graph.modifier(modifier_id)
                self.assertEqual((args["BuildingType"], args["YieldType"], int(args["Amount"])),
                                 (building, yield_type, 50))


if __name__ == "__main__":
    unittest.main(verbosity=2)
