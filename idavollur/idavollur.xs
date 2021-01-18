// Idavollur: Based on highland, but with mountains instead

// Constants

// Decoration
string FORESTFLOORPINE = "ForestFloorPine";
string FORESTFLOORPINESNOW = "ForestFloorPineSnow";
string NORSERIVER = "Norse River";

// Least to most snow coverage
string SNOWGRASS25 = "SnowGrass25";
string SNOWSAND25 = "SnowSand25";

string SNOWGRASS50 = "SnowGrass50";
string SNOWSAND50 = "SnowSand50";

string SNOWGRASS75 = "SnowGrass75";
string SNOWSAND75 = "SnowSand75";

// Main entry point for random map script
void main(void)
{
   // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles = 9000;
   if(cMapSize == 1)
   {
     playerTiles = 14040;
     rmEchoInfo("Large map");
   }

   // Force the map to be square.
   int size = 2.1 * sqrt(cNumberNonGaiaPlayers*playerTiles / 0.9);
   rmEchoInfo("Map size = "+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Initialize the map terrain
   rmSetSeaLevel(0.0);
   rmTerrainInitialize("cliffNorseA", 12.0);
   rmSetLightingSet("olympus");

   // Define some classes.
   int classIsland=rmDefineClass("island");
   int classPlayerCore=rmDefineClass("player core");
   int classPlayer=rmDefineClass("player");
   int classForest=rmDefineClass("forest");
   int classPasses = rmDefineClass("passes");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   rmDefineClass("center");

   int classCliff=rmDefineClass("cliff");
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 60.0);

   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(1), rmZTilesToFraction(1), 1.0-rmXTilesToFraction(1), 1.0-rmZTilesToFraction(1));
   int farEdgeConstraint=rmCreateBoxConstraint("far edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));
   int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8), 0.01);

   int centerConstraint = rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 60.0);
   int shortCenterConstraint = rmCreateClassDistanceConstraint("small stay away from center", rmClassID("center"), 60.0);

   // Player area constraint.
   int islandConstraint = rmCreateClassDistanceConstraint("stay away from islands", classIsland, 30.0);
   int playerConstraint = rmCreateClassDistanceConstraint("bonus Settlement stay away from players", classPlayer, 20);

   // corner constraint.
   int cornerConstraint = rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint = rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraint.
   int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 50.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);

   // Far starting settlement constraint.
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 50.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 25.0);

   // Gold
   int avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold = rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Pigs/pigs
   int avoidHerdable = rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);

   // Bonus huntable
   int classBonusHuntable = rmDefineClass("bonus huntable");
   int avoidBonusHuntable = rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 15.0);
   int avoidFood = rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidFoodFar = rmCreateTypeDistanceConstraint("avoid food by more", "food", 20.0);
   int avoidPredator = rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand = rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
   int shortAvoidImpassableLand = rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);
   int tinyAvoidImpassableLand = rmCreateTerrainDistanceConstraint("tiny avoid impassable land", "Land", false, 2.0);
   int avoidAll = rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int farAvoidAll = rmCreateTypeDistanceConstraint("far avoid all", "all", 10.0);
   int farAvoidImpassableLand = rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);

   //Forest close constraint
   int closeForestConstraint=rmCreateClassDistanceConstraint("closeforest v oakforest", rmClassID("forest"), 6.0);

   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("Starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   // towers avoid other towers
   int startingTowerID=rmCreateObjectDef("Starting tower");
   rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTowerID, 22.0);
   rmSetObjectDefMaxDistance(startingTowerID, 26.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, farAvoidAll);

   // towers avoid other towers
   int startingTower2ID=rmCreateObjectDef("Starting tower2");
   rmAddObjectDefItem(startingTower2ID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTower2ID, 22.0);
   rmSetObjectDefMaxDistance(startingTower2ID, 26.0);
   rmAddObjectDefConstraint(startingTower2ID, avoidTower);
   rmAddObjectDefConstraint(startingTower2ID, farAvoidAll);

   // Gold nearest the player encampment
   // gold avoids gold
   int startingGoldID = rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   // Cows nearest the player encampment
   int closeCowID = rmCreateObjectDef("close cow");
   rmAddObjectDefItem(closeCowID, "cow", 3, 2.0);
   rmSetObjectDefMinDistance(closeCowID, 25.0);
   rmSetObjectDefMaxDistance(closeCowID, 30.0);
   rmAddObjectDefConstraint(closeCowID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeCowID, avoidFood);
   rmAddObjectDefConstraint(closeCowID, avoidAll);
   rmAddObjectDefConstraint(closeCowID, closeForestConstraint);

   // Deer nearest the player encampment
   int closeDeerID=rmCreateObjectDef("close deer");
   rmAddObjectDefItem(closeDeerID, "deer", rmRandInt(6,8), 4.0);
   rmSetObjectDefMinDistance(closeDeerID, 25.0);
   rmSetObjectDefMaxDistance(closeDeerID, 30.0);
   rmAddObjectDefConstraint(closeDeerID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeDeerID, avoidFood);
   rmAddObjectDefConstraint(closeDeerID, closeForestConstraint);
   rmAddObjectDefConstraint(closeDeerID, avoidAll);

   // Nearby boar
   int closeBoarID = rmCreateObjectDef("close boar");
   float boarChance = rmRandFloat(0, 1);
   if(boarChance < 0.3)
   {
      rmAddObjectDefItem(closeBoarID, "boar", 2, 1.0);
   }
   else if(boarChance < 0.6)
   {
      rmAddObjectDefItem(closeBoarID, "boar", 3, 4.0);
   }
   else
   {
      // Extra lucky, four nearby boars
      rmAddObjectDefItem(closeBoarID, "boar", 4, 1.0);
   }

   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 50.0);

   rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeBoarID, closeForestConstraint);
   rmAddObjectDefConstraint(closeBoarID, avoidAll);

   // Medium ( by distance ) objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int mediumCowsID = rmCreateObjectDef("medium cows");
   rmAddObjectDefItem(mediumCowsID, "cow", rmRandInt(2,3), 4.0);
   rmSetObjectDefMinDistance(mediumCowsID, 50.0);
   rmSetObjectDefMaxDistance(mediumCowsID, 70.0);
   rmAddObjectDefConstraint(mediumCowsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumCowsID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumCowsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumCowsID, closeForestConstraint);


   // For this map, pick how many deer are in a grouping.
   int numHuntable = rmRandInt(8, 14);

   int mediumDeerID = rmCreateObjectDef("medium deer");
   rmAddObjectDefItem(mediumDeerID, "deer", numHuntable, 6.0);
   rmSetObjectDefMinDistance(mediumDeerID, 40.0);
   rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
   rmAddObjectDefConstraint(mediumDeerID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumDeerID, cliffConstraint);
   rmAddObjectDefConstraint(mediumDeerID, closeForestConstraint);
   rmAddObjectDefConstraint(mediumDeerID, avoidAll);


   // far objects

   // gold avoids gold, Settlements and TCs
   int farGoldID = rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 100.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, edgeConstraint);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);

   int farCowsID = rmCreateObjectDef("far cows");
   rmAddObjectDefItem(farCowsID, "cow", rmRandInt(1,4), 4.0);
   rmSetObjectDefMinDistance(farCowsID, 80.0);
   rmSetObjectDefMaxDistance(farCowsID, 150.0);
   rmAddObjectDefConstraint(farCowsID, avoidHerdable);
   rmAddObjectDefConstraint(farCowsID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farCowsID, closeForestConstraint);

   // avoid TCs
   int farPredatorID = rmCreateObjectDef("far predator");
   float predatorCountChance = rmRandFloat(0, 1);
   if(predatorCountChance < 0.50)
   {
      rmAddObjectDefItem(farPredatorID, "polar bear", 1, 4.0);
   }
   else if (predatorCountChance < 0.75)
   {
      rmAddObjectDefItem(farPredatorID, "polar bear", 2, 2.0);
   }
   else
   {
      // Extra dangerous case -- not likely -- three polar bears appear!
      rmAddObjectDefItem(farPredatorID, "polar bear", 3, 1.0);
   }

   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, closeForestConstraint);

   int farPolarBearID = rmCreateObjectDef("far polar bear");
   rmAddObjectDefItem(farPolarBearID, "polar bear", 1, 0.0);
   rmSetObjectDefMinDistance(farPolarBearID, 50.0);
   rmSetObjectDefMaxDistance(farPolarBearID, 100.0);
   rmAddObjectDefConstraint(farPolarBearID, farStartingSettleConstraint);

   // Add skraelings who beat you up!
   int skraelingCount = rmRandInt(1, 3);
   int farSkraelingID = rmCreateObjectDef("far skraeling");
   rmAddObjectDefItem(farSkraelingID, "skraeling", skraelingCount, 3.0);
   rmSetObjectDefMinDistance(farSkraelingID, 50.0);
   rmSetObjectDefMaxDistance(farSkraelingID, 150.0);
   rmAddObjectDefConstraint(farSkraelingID, farStartingSettleConstraint);


   // Coming up, we add three bonus huntables
   // They're all structured roughly the same; they're just in different groupings
   // We randomly choose between deer, caribou, and elk as a bonus huntable

   int avoidHuntable = rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);
   int bonusHuntableID = rmCreateObjectDef("bonus huntable");
   float bonusChance = rmRandFloat(0, 1);
   if(bonusChance < 0.5)
   {
      rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(8, 12), 2.0);
   }
   else if(bonusChance < 0.75)
   {
      rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(6,10), 3.0);
   }
   else
   {
      rmAddObjectDefItem(bonusHuntableID, "elk", rmRandInt(4,8), 3.0);
   }

   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, closeForestConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidAll);

   // Bonus huntable 1
   int bonusHuntableID2 = rmCreateObjectDef("bonus huntable2");
   bonusChance = rmRandFloat(0, 1);
   if(bonusChance < 0.5)
   {
      rmAddObjectDefItem(bonusHuntableID2, "deer", rmRandInt(8, 12), 2.0);
   }
   else if(bonusChance < 0.75)
   {
      rmAddObjectDefItem(bonusHuntableID2, "caribou", rmRandInt(6,10), 3.0);
   }
   else
   {
      rmAddObjectDefItem(bonusHuntableID2, "elk", rmRandInt(4,8), 3.0);
   }

   rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID2, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntableID2, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID2, avoidAll);
   rmAddObjectDefConstraint(bonusHuntableID2, closeForestConstraint);

   int bonusHuntableID3 = rmCreateObjectDef("bonus huntable3");
   bonusChance = rmRandFloat(0, 1);
   if(bonusChance < 0.5)
   {
      rmAddObjectDefItem(bonusHuntableID3, "deer", rmRandInt(8, 12), 2.0);
   }
   else if(bonusChance < 0.75)
   {
      rmAddObjectDefItem(bonusHuntableID3, "caribou", rmRandInt(6,10), 3.0);
   }
   else
   {
      // This time they get quite lucky and get both elk and caribou
      rmAddObjectDefItem(bonusHuntableID3, "elk", rmRandInt(2,6), 3.0);
      rmAddObjectDefItem(bonusHuntableID3, "caribou", rmRandInt(4,8), 3.0);
   }

   rmSetObjectDefMinDistance(bonusHuntableID3, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID3, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntableID3, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID3, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID3, avoidAll);
   rmAddObjectDefConstraint(bonusHuntableID3, cliffConstraint);
   rmAddObjectDefConstraint(bonusHuntableID3, closeForestConstraint);

   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

   // Relics avoid TCs

   int relicID = rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 40.0);
   rmSetObjectDefMaxDistance(relicID, 80.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 30.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(relicID, centerConstraint);
   rmAddObjectDefConstraint(relicID, closeForestConstraint);




   // ===================================Done defining objects=============================================

   // ###################################### Create areas ###############################################


   rmPlacePlayersCircular(0.4, 0.45, rmDegreesToRadians(5.0));

   // Creating the mountain in the center of the map
   int centerID = rmCreateArea("center");
   rmSetAreaSize(centerID, 0.0005, 0.0005);
   rmSetAreaLocation(centerID, 0.5, 0.5);
   rmSetAreaMinBlobs(centerID, 1);
   rmSetAreaMaxBlobs(centerID, 2);
   rmSetAreaMinBlobDistance(centerID, 0.0);
   rmSetAreaMaxBlobDistance(centerID, 2.5);
   rmSetAreaCoherence(centerID, 0.1);
   rmAddAreaToClass(centerID, rmClassID("center"));
   rmBuildArea(centerID);

   int centerAreaConstraint=rmCreateAreaDistanceConstraint("stay away from center mountain", centerID, 70);

   // Creating Player Cores
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player core"+i);
      rmSetAreaSize(id, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
      rmAddAreaToClass(id, classPlayerCore);
      rmSetAreaCoherence(id, 1.0);
      rmSetAreaBaseHeight(id, 40.0);
      rmSetAreaLocPlayer(id, i);
      rmBuildArea(id);
   }

   // Create connections
   int passesID = rmCreateConnection("passes");
   rmSetConnectionType(passesID, cConnectPlayers, false, 1.0);
   rmSetConnectionWidth(passesID, 28, 2);
   // TODO debugging: warn on fail to connect
   rmSetConnectionWarnFailure(passesID, true);
   rmSetConnectionBaseHeight(passesID, 4.0);
   rmSetConnectionHeightBlend(passesID, 5.0);
   rmSetConnectionSmoothDistance(passesID, 4.0);

   rmSetConnectionPositionVariance(passesID, 0.5);

   // Start and end of passes depend on the center area constraint
   rmAddConnectionStartConstraint(passesID, centerAreaConstraint);
   rmAddConnectionEndConstraint(passesID, centerAreaConstraint);

   rmAddConnectionToClass(passesID, classPasses);
   rmAddConnectionStartConstraint(passesID, edgeConstraint);
   rmAddConnectionEndConstraint(passesID, edgeConstraint);

   // Replace CliffNorseA in the joining areas with SnowGrass75
   // CliffNorseA is a direct result of using CliffNorseA as terrain basis
   // this will be removed / changed
   rmAddConnectionTerrainReplacement(passesID, "cliffNorseA", SNOWGRASS75);


   // Create extra connection for 2 player?
   // In this instance, we want to have the river broken in two places
   // when there are two players, if that's possible to do easily.

   int passesConstraint = rmCreateClassDistanceConstraint("stay away from passes", classPasses, 80.0);

   if (cNumberNonGaiaPlayers < 3)
   {
      int teamPassID=rmCreateConnection("team pass");
      rmSetConnectionType(teamPassID, cConnectPlayers, false, 1.0);
      rmSetConnectionWarnFailure(teamPassID, false);
      rmSetConnectionWidth(teamPassID, 26, 2);

      rmSetConnectionBaseHeight(teamPassID, 4.0);
      rmSetConnectionHeightBlend(teamPassID, 5.0);
      rmSetConnectionSmoothDistance(teamPassID, 4.0);

      rmAddConnectionStartConstraint(teamPassID, edgeConstraint);
      rmAddConnectionEndConstraint(teamPassID, edgeConstraint);
      rmAddConnectionStartConstraint(teamPassID, passesConstraint);
      rmAddConnectionEndConstraint(teamPassID, passesConstraint);
      rmSetConnectionPositionVariance(teamPassID, -1);
      rmAddConnectionTerrainReplacement(teamPassID, "cliffNorseA", SNOWSAND25);
   }

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(200);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      id = rmCreateArea("Player"+i);
      rmSetPlayerArea(i, id);
      rmSetAreaSize(id, 0.5, 0.5);
      rmAddAreaToClass(id, classIsland);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaWarnFailure(id, false);
      rmSetAreaMinBlobs(id, 3);
      rmSetAreaMaxBlobs(id, 6);
      rmSetAreaMinBlobDistance(id, 7.0);
      rmSetAreaMaxBlobDistance(id, 12.0);
      rmSetAreaCoherence(id, 0.5);
      rmSetAreaBaseHeight(id, 6.0);
      rmSetAreaSmoothDistance(id, 10);
      rmSetAreaHeightBlend(id, 2);
      rmAddAreaConstraint(id, islandConstraint);
      rmAddAreaConstraint(id, cornerOverlapConstraint);
      if (cNumberNonGaiaPlayers > 2)
      {
         rmAddAreaConstraint(id, centerConstraint);
      }

      rmSetAreaLocPlayer(id, i);
      rmAddConnectionArea(teamPassID, id);
      rmAddConnectionArea(passesID, id);
      rmSetAreaTerrainType(id, SNOWGRASS50);
      rmAddAreaTerrainLayer(id, SNOWGRASS75, 4, 7);
      rmAddAreaTerrainLayer(id, SNOWGRASS75, 2, 4);
      rmAddAreaTerrainLayer(id, SNOWGRASS75, 0, 2);
   }

   // Build all areas
   rmBuildAllAreas();
   rmBuildConnection(passesID);
   if (teamPassID != passesID)
   {
        rmBuildConnection(teamPassID);
   }
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 3);
   rmPlaceObjectDefPerPlayer(startingTower2ID, true, 1);

   // Home Settlement
   id=rmAddFairLoc("Settlement", false, true, 40, 100, 40, 16, true); /* bool forward bool inside */
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);
   rmAddFairLocConstraint(id, avoidSettlement);

   id=rmAddFairLoc("Settlement", true, false,  40, 100, 40, 16);
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);
   rmAddFairLocConstraint(id, avoidSettlement);

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
         {
            int settleArea = rmCreateArea("settlement area"+i +j, rmAreaID("Player"+i));
            rmSetAreaLocation(settleArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
            rmBuildArea(settleArea);
            rmPlaceObjectDefAtAreaLoc(id, i, settleArea);
         }
      }
   }

   /// Snow Pine Forest.

   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
   int oakForestConstraint=rmCreateClassDistanceConstraint("oakforest v oakforest", rmClassID("forest"), 30.0);

   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int forestCount=8*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(forestID, false);

      rmSetAreaForestType(forestID, "snow pine forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
      rmAddAreaToClass(forestID, classForest);
      rmSetAreaTerrainType(forestID, FORESTFLOORPINE);
      rmAddAreaTerrainLayer(forestID, FORESTFLOORPINESNOW, 0, 2);

      rmSetAreaMinBlobs(forestID, 2);
      rmSetAreaMaxBlobs(forestID, 4);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 20.0);
      rmSetAreaCoherence(forestID, 0.0);

      rmSetAreaBaseHeight(forestID, 0);
      rmSetAreaSmoothDistance(forestID, 4);
      rmSetAreaHeightBlend(forestID, 2);


      if(rmBuildArea(forestID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==3)
         break;
      }
      else
      {
         failCount=0;
      }
   }


/// Player Forests.

   int playerForestCount=8*cNumberNonGaiaPlayers;
   int playerfailCount=0;
   for(i=0; <forestCount)
   {
      int playerForestID=rmCreateArea("playerForest"+i);
      rmSetAreaSize(playerForestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(160));
      rmSetAreaWarnFailure(playerForestID, false);
      rmSetAreaForestType(playerForestID, "pine forest");
      rmAddAreaConstraint(playerForestID, forestSettleConstraint);
      rmAddAreaConstraint(playerForestID, forestObjConstraint);
      rmAddAreaConstraint(playerForestID, oakForestConstraint);
      rmAddAreaConstraint(playerForestID, avoidImpassableLand);
      rmAddAreaToClass(playerForestID, classForest);

      rmSetAreaMinBlobs(playerForestID, 2);
      rmSetAreaMaxBlobs(playerForestID, 4);
      rmSetAreaMinBlobDistance(playerForestID, 16.0);
      rmSetAreaMaxBlobDistance(playerForestID, 20.0);
      rmSetAreaCoherence(playerForestID, 0.0);

      // Hill trees? TODO the fact that this is a question means this ought to be investigated
      if(rmRandFloat(0.0, 1.0)<0.6)
      {
         rmSetAreaBaseHeight(playerForestID, rmRandFloat(10.0, 12.0));
         rmSetAreaSmoothDistance(playerForestID, 14);
         rmSetAreaHeightBlend(playerForestID, 2);
      }

      if(rmBuildArea(playerForestID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         playerfailCount++;
         if(playerfailCount==3)
         break;
      }
      else
      {
         playerfailCount=0;
      }
   }

   // Elev.
   failCount=0;
   int numTries1=20*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 10.0);
   for(i=0; <numTries1)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
      // TODO variablize this chance
      if(rmRandFloat(0.0, 1.0) < 0.7)
      {
         rmSetAreaTerrainType(elevID, SNOWSAND25);
         rmAddAreaTerrainLayer(elevID, SNOWGRASS50, 0, 4);
      }
      rmSetAreaBaseHeight(elevID, rmRandFloat(6.0, 10.0));
      rmSetAreaHeightBlend(elevID, 2);
      rmSetAreaSmoothDistance(elevID, 20);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 6 times in a row.
         failCount++;
         if(failCount==6)
         break;
      }
      else
      {
         failCount=0;
      }
   }

   // Cliffage
   // TODO this is a pretty serious block
   int numTries=3*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int cliffID=rmCreateArea("cliff"+i);
      rmSetAreaWarnFailure(cliffID, false);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(180));
      rmSetAreaCliffType(cliffID, "Norse");
      rmAddAreaConstraint(cliffID, cliffConstraint);
      rmAddAreaToClass(cliffID, classCliff);
      rmAddAreaConstraint(cliffID, avoidBuildings);
      rmAddAreaConstraint(cliffID, farAvoidImpassableLand);
      //   rmAddAreaConstraint(cliffID, shortCoreBonusConstraint);
      rmAddAreaConstraint(cliffID, avoidAll);
      rmSetAreaMinBlobs(cliffID, 10);
      rmSetAreaMaxBlobs(cliffID, 10);
      rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
      rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, true);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaMinBlobDistance(cliffID, 16.0);
      rmSetAreaMaxBlobDistance(cliffID, 40.0);
      rmSetAreaCoherence(cliffID, 0.25);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaHeightBlend(cliffID, 2);

      if(rmBuildArea(cliffID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==3)
         break;
      }
      else
      {
         failCount=0;
      }
   }



   for(i=1; <cNumberPlayers*40)
   {
      int id6=rmCreateArea("grass patch"+i);
      rmSetAreaSize(id6, rmAreaTilesToFraction(10), rmAreaTilesToFraction(75));
      rmSetAreaTerrainType(id6, SNOWGRASS75);
      rmSetAreaMinBlobs(id6, 1);
      rmSetAreaMaxBlobs(id6, 5);
      rmSetAreaMinBlobDistance(id6, 16.0);
      rmSetAreaMaxBlobDistance(id6, 40.0);
      rmSetAreaCoherence(id6, 0.0);
      rmAddAreaConstraint(id6, shortAvoidImpassableLand);
      rmAddAreaConstraint(id6, closeForestConstraint);
      rmBuildArea(id6);
   }

   for(i=1; <cNumberPlayers*40)
   {
      int id7 = rmCreateArea("dirt patch"+i);
      rmSetAreaSize(id7, rmAreaTilesToFraction(10), rmAreaTilesToFraction(75));
      rmSetAreaTerrainType(id7, SNOWSAND50);
      rmAddAreaTerrainLayer(id7, SNOWGRASS75, 0, 2);
      rmSetAreaMinBlobs(id7, 1);
      rmSetAreaMaxBlobs(id7, 5);
      rmSetAreaMinBlobDistance(id7, 16.0);
      rmSetAreaMaxBlobDistance(id7, 40.0);
      rmSetAreaCoherence(id7, 0.0);
      rmAddAreaConstraint(id7, shortAvoidImpassableLand);
      rmAddAreaConstraint(id7, closeForestConstraint);
      rmBuildArea(id7);
   }


   // PLACE STARTING TOWN AND RESOURCES

   // Straggler trees.

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
   rmAddObjectDefConstraint(stragglerTreeID, avoidImpassableLand);
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3, 7));



   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Pigs
   rmPlaceObjectDefPerPlayer(closeCowID, true);

   // Gazelle
   rmPlaceObjectDefPerPlayer(closeDeerID, false);

   // Medium things....

   // Gold
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(mediumGoldID, 0, rmAreaID("player"+i));
   }

   // Pigs
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(mediumCowsID, 0, rmAreaID("player"+i));
   }

   // Far things.
   // Player Far Gold, need goldNum since it randomizes for each i
   int goldNum = rmRandInt(1,3);
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(farGoldID, false, rmAreaID("player"+i), goldNum);
   }

   // Relics.
   int relicNumB = rmRandInt(1,3);
   rmPlaceObjectDefPerPlayer(relicID, false, relicNumB);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

   for(i=1; <cNumberPlayers)
   {
      // Far Predators
      rmPlaceObjectDefInArea(farPolarBearID, false, rmAreaID("player"+i));
      rmPlaceObjectDefInArea(farSkraelingID, false, rmAreaID("player"+i));
      // Bonus huntable
      rmPlaceObjectDefInArea(bonusHuntableID, false, rmAreaID("player"+i));
      // Cows
      int cowCount = rmRandInt(1,4);
      rmPlaceObjectDefInArea(farCowsID, false, rmAreaID("player"+i), cowCount);
   }

   // Bonus huntable
   int bonusHuntableCount = rmRandInt(4, 5);
   for (j=1; <cNumberNonGaiaPlayers)
   {
      // This code was previously broken in highland.xs because it was
      // easily possible for bonusCount > cNumberNonGaiaPlayers
      for(i=1; < bonusHuntableCount)
      {
        rmPlaceObjectDefInArea(bonusHuntableID2, false, rmAreaID("player"+j));
        rmPlaceObjectDefInArea(bonusHuntableID3, false, rmAreaID("player"+j));
      }
   }

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);

   // Text
   rmSetStatusText("",0.60);

   // Random trees.
   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   int groundDecorationID = rmCreateObjectDef("ground decoration");
   rmAddObjectDefItem(groundDecorationID, "heavenlight", rmRandInt(0,1), 3.0);
   rmAddObjectDefItem(groundDecorationID, "mist", rmRandInt(6,8), 6.0);
   rmSetObjectDefMinDistance(groundDecorationID, 0.0);
   rmSetObjectDefMaxDistance(groundDecorationID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(groundDecorationID, avoidAll);
   rmAddObjectDefConstraint(groundDecorationID, avoidImpassableLand);
   rmAddObjectDefConstraint(groundDecorationID, avoidBuildings);
   rmPlaceObjectDefAtLoc(groundDecorationID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
}