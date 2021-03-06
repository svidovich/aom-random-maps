// Constants

// Terrain names for decorating
string SNOWGRASS25 = "SnowGrass25";
string CLIFFNORSEA = "cliffNorseA";
string CLIFFNORSEB = "cliffNorseB";



/*
General Notes
=============

rm API documentation:
https://www.aoebbs.net/AOMCode/aom/scripting/xs/rm/package-summary.html

RandomMap API documentation:
https://www.aoebbs.net/AOMCode/aom/scripting/xs/rm/RandomMap.html

We get some things for free:
int cMapSize: set to integer 1 if large map is chosen, 0 if normal is chosen
int cNumberPlayers: The total number of players, including Gaia
int cNumberNonGaiaPlayers: The total number of players, excluding Gaia
int cNumberTeams: The total number of teams

You _cannot_ declare and use float constants in mathematical operations
for reasons I don't fully understand
*/

// Main entry point for random map script
void main(void)
{


  // Text
   rmSetStatusText("",0.1);

   // Set size.
   int playerTiles = 9000;
   if(cMapSize == 1)
   {
      playerTiles = 14040;
      // void rmEchoInfo(string echoString, int level)
      // Echoes an info string to the debugger output, can not be seen in AoT.
      rmEchoInfo("Large map");
   }
   int sizel=0;
   int sizew=0;
   // float rmRandFloat(int intervalStart, int intervalStop)
   // returns a random floating point number between intervalStart
   // and intervalStop, inclusive.
   float handedness = rmRandFloat(0, 1);

   // Flip a coin.
   if(handedness < 0.5)
   {
      // If it's tails, make the map longer than it is wide.
      sizel=2.22 * sqrt(cNumberNonGaiaPlayers * playerTiles);
      sizew=1.8 * sqrt(cNumberNonGaiaPlayers * playerTiles);
   }
   else
   {
      // If it's heads, make the map wider than it is long.
      sizel=1.8 * sqrt(cNumberNonGaiaPlayers * playerTiles);
      sizew=2.22 * sqrt(cNumberNonGaiaPlayers * playerTiles);
   }

   // Map sizing procedure
   // Math example:
   // Suppose it's a large map, and we get handedness < 0.5, and we have 3
   // non Gaia players. Then, we get
   // sizel = 2.22 * sqrt(3 + 11700) ~ 240
   // sizew = 1.8 * sqrt(3 + 11700) ~ 195
   // There must be some kind of duck typing / auto-casting going on
   // because those _certainly_ aren't integers.

   rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
   // Set the map size based on our coin flip results.
   rmSetMapSize(sizel, sizew);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   // void rmTerrainInitialize(string baseTerrain, float height)
   // Initializes the terrain to the base type and height.
   rmTerrainInitialize(CLIFFNORSEA, 12.0);

   // Define some classes.
   // int rmDefineClass(string className)
   // Define a class with the given name.
   int classPlayer=rmDefineClass("player");
   // We will use this later when initializing objects
   // We assign the first settlement to this class.
   int startingSettlementClassID = rmDefineClass("starting settlement");
   // What are these for?
   int connectionClass=rmDefineClass("connection");
   int patchClass=rmDefineClass("patchClass");


   // Create a edge of map constraint.
   // int rmCreateBoxConstraint(
   //    string name,
   //    float startX,
   //    float startZ,
   //    float endX,
   //    float endZ,
   //    float bufferFraction
   // )
   // Makes a box constraint and forces something to remain in it.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
   // We don't want the connections between the valleys where the players reside to be at the edge of the map.
   int connectionEdgeConstraint=rmCreateBoxConstraint("connections avoid edge of map", rmXTilesToFraction(16), rmZTilesToFraction(16), 1.0-rmXTilesToFraction(16), 1.0-rmZTilesToFraction(16));

   // Player area constraint.
   // int rmCreateClassDistanceConstraint(string name, int classID, float distance)
   // Creates a class distance constraint that forces something to stay away from everything
   // in the given class.
   // Create a constraint for use later that allows us to distance things from the players
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);

   // Connection
   int connectionConstraint=rmCreateClassDistanceConstraint("stay away from connection", connectionClass, 4.0);

   // Settlement constraint.
   // int rmCreateTypeDistanceConstraint(string name, string typeName, float distance)
   // Creates a type distance constraint the forces something to say away from everything
   // of the given type.
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 40.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", startingSettlementClassID, 40.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Animals
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 10.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 10.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 10.0);

   // Avoid impassable land
   // int rmCreateTerrainDistanceConstraint(string name, string type, bool passable, float distance)
   // Creates a constrant to avoid terrain that is boolean passable.
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 6.0);
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("forests avoid impassable land", "land", false, 18.0);
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);

   // -------------Define objects
   // Close Objects
   // Object Definition API documentation:
   // https://www.aoebbs.net/AOMCode/aom/scripting/xs/rm/ObjectDef.html


   // int rmCreateObjectDef(string name)
   // Creates a new object definition, returns its ID.
   int startingSettlementID = rmCreateObjectDef("starting settlement");
   // void rmAddObjectDefItem(int definitionID, string unitName, int count, float clusterDistance)
   // Adds <count> objects to an object definition with id <definitionID>,
   // clustered at a distance of <clusterDistance>
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   // bool rmAddObjectDefToClass(int objectDefinitionID, int classID)
   // Add a given object to the class given by classID.
   rmAddObjectDefToClass(startingSettlementID, startingSettlementClassID);
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   // towers avoid other towers
   int startingTowerID=rmCreateObjectDef("Starting tower");
   rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
   // We don't want the starting towers to be too close together, or
   // too far apart.
   rmSetObjectDefMinDistance(startingTowerID, 22.0);
   rmSetObjectDefMaxDistance(startingTowerID, 28.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   // We also don't want them to be on impassable land.
   rmAddObjectDefConstraint(startingTowerID, shortAvoidImpassableLand);

   // gold avoids gold
   // That is, any the first gold mine generated shouldn't be too close
   // to any other gold mine generated
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);

   int closeCowsID=rmCreateObjectDef("close cows");
   rmAddObjectDefItem(closeCowsID, "cow", 4, 2.0);
   rmSetObjectDefMinDistance(closeCowsID, 25.0);
   rmSetObjectDefMaxDistance(closeCowsID, 30.0);
   rmAddObjectDefConstraint(closeCowsID, avoidFood);

   int numChicken = 0;
   int numBerry = 0;
   float berryChance = rmRandFloat(0,1);
   if(berryChance < 0.25)
   {
      numChicken = 10;
      numBerry = 6;
   }
   else if(berryChance < 0.75)
   {
      numChicken = 15;
      numBerry = 10;
   }
   else
   {
      numChicken = 20;
      numBerry = 15;
   }

   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", numChicken, 2.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);

   // Sometimes half of my chickens end up in a gold mine, which
   // sucks. Let's be sure that we avoid gold when spawning the chickens.
   rmAddObjectDefConstraint(closeChickensID, shortAvoidGold);

   int closeBerriesID = rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", numBerry, 2.0);
   rmSetObjectDefMinDistance(closeBerriesID, 20.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 25.0);
   rmAddObjectDefConstraint(closeBerriesID, avoidFood);

   int closeHuntableID = rmCreateObjectDef("close huntable");
   float huntableNumber = rmRandFloat(0, 1);

   if(huntableNumber < 0.3)
   {
      rmAddObjectDefItem(closeHuntableID, "deer", 8, 2.0);
   }
   else if(huntableNumber < 0.6)
   {
      rmAddObjectDefItem(closeHuntableID, "caribou", 6, 2.0);
   }
   else
   {
      rmAddObjectDefItem(closeHuntableID, "elk", 6, 2.0);
   }

   // void rmSetObjectDefMinDistance(int definitionID, float distance)
   // Set the maximum distance ( TODO: From what? ) for the object definition
   // ( in meters )
   rmSetObjectDefMinDistance(closeHuntableID, 30.0);
   rmSetObjectDefMaxDistance(closeHuntableID, 50.0);
   rmAddObjectDefConstraint(closeHuntableID, shortAvoidSettlement);
   rmAddObjectDefConstraint(closeHuntableID, shortAvoidImpassableLand);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // Medium Objects

   // Text
   rmSetStatusText("",0.20);

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 70.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumGoldID, forestObjConstraint);

   // For this map, pick how many deer in a grouping. Assign this
   int numHuntable=rmRandInt(12, 20);

   int mediumDeerID=rmCreateObjectDef("medium deer");
   rmAddObjectDefItem(mediumDeerID, "deer", numHuntable, 3.0);
   rmSetObjectDefMinDistance(mediumDeerID, 60.0);
   rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
   rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumDeerID, forestObjConstraint);

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   // Why were the minDistance and maxDistance constraints removed
   // for the far gold mine?
/*   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0); */
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoldID, forestObjConstraint);

   // goats avoid TCs
   int farCowsID=rmCreateObjectDef("far cows");
   rmAddObjectDefItem(farCowsID, "cow", 6, 4.0);
   rmSetObjectDefMinDistance(farCowsID, 80.0);
   rmSetObjectDefMaxDistance(farCowsID, 150.0);
   rmAddObjectDefConstraint(farCowsID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farCowsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farCowsID, forestObjConstraint);

   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   rmAddObjectDefItem(farPredatorID, "wolf", 1, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, forestObjConstraint);

   int farPredator2ID=rmCreateObjectDef("far predator 2");
   rmAddObjectDefItem(farPredator2ID, "bear", 1, 4.0);
   rmSetObjectDefMinDistance(farPredator2ID, 50.0);
   rmSetObjectDefMaxDistance(farPredator2ID, 100.0);
   rmAddObjectDefConstraint(farPredator2ID, avoidPredator);
   rmAddObjectDefConstraint(farPredator2ID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredator2ID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredator2ID, forestObjConstraint);

   // This map will either use deer, elk, caribou as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusHuntableChance = rmRandFloat(0, 1);

   if(bonusHuntableChance < 0.3)
   {
      rmAddObjectDefItem(bonusHuntableID, "deer", 12, 2.0);
   }
   else if(bonusHuntableChance < 0.6)
   {
      rmAddObjectDefItem(bonusHuntableID, "elk", 10, 2.0);
   }
   else
   {
      rmAddObjectDefItem(bonusHuntableID, "caribou", 8, 2.0);
   }

   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   // Stay away from myself?
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   // Stay away from other huntable herds
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   // Add the bonusHuntableID to the bonusHuntable class
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   // Stay away from impassable land
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
   // Stay away from settlements
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   // Stay away from forsts
   rmAddObjectDefConstraint(bonusHuntableID, forestObjConstraint);

   // hunted avoids hunted and TCs
   int bonusHuntableID2=rmCreateObjectDef("bonus huntable 2");
   // Roll again for another bonus huntable
   float additionalBonusHuntableChance = rmRandFloat(0, 1);

   if(additionalBonusHuntableChance < 0.3)
   {
      rmAddObjectDefItem(bonusHuntableID2, "deer", 10, 2.0);
   }
   else if(additionalBonusHuntableChance < 0.6)
   {
      rmAddObjectDefItem(bonusHuntableID2, "elk", 12, 2.0);
   }
   else
   {
      rmAddObjectDefItem(bonusHuntableID2, "caribou", 8, 2.0);
   }

   rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID2, rmXFractionToMeters(0.5));
   // Make sure that the bonus huntable herds aren't too close together
   rmAddObjectDefConstraint(bonusHuntableID2, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, avoidHuntable);
   // Add second bonus huntable herd to the same class as the previous one
   rmAddObjectDefToClass(bonusHuntableID2, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID2, forestObjConstraint);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);

   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

 // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 2, 0.0);
   rmSetObjectDefMinDistance(relicID, 30.0);
   rmSetObjectDefMaxDistance(relicID, 130.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 40.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, forestObjConstraint);


   // -------------Done defining objects

  // Text
   rmSetStatusText("",0.40);


   rmPlacePlayersCircular(0.30, 0.40, rmDegreesToRadians(4.0));

    // Build team areas.
   int teamClass=rmDefineClass("teamClass");
   int baseMountainWidth = 0;
   int connectionWidth = 0;
   if (cNumberTeams < 3)
   {
      baseMountainWidth = 30;
      connectionWidth = 30;
   }
   // Support large games by giving additional room
   else if (cNumberTeams < 6)
   {
      baseMountainWidth = 20;
      connectionWidth = 25;
   }
   // Support _very_ large games by giving additional room
   else
   {
       baseMountainWidth = 15;
       connectionWidth = 20;
   }

   int teamConstraint=rmCreateClassDistanceConstraint("how wide the mountain is", teamClass, baseMountainWidth);

   // Set up a connection... we'll add all the team areas to it.
   int connectionID=rmCreateConnection("passes");
   rmAddConnectionTerrainReplacement(connectionID, CLIFFNORSEA, SNOWGRASS25);
   rmAddConnectionTerrainReplacement(connectionID, CLIFFNORSEB, SNOWGRASS25);
   // Create a connection that connects areas, but not all areas
   // When using cConnectAreas, you must specify each area to be connected
   // by calling rmAddConnectionArea
   rmSetConnectionType(connectionID, cConnectAreas, false, 1.0);
   rmSetConnectionWarnFailure(connectionID, false);
   rmSetConnectionWidth(connectionID, connectionWidth, 4);
   rmSetConnectionTerrainCost(connectionID, CLIFFNORSEA, 5.0);
   rmSetConnectionTerrainCost(connectionID, CLIFFNORSEB, 3.0);
   rmSetConnectionPositionVariance(connectionID, 0.3);
   rmSetConnectionBaseHeight(connectionID, 0.0);
   rmSetConnectionHeightBlend(connectionID, 2);
   rmAddConnectionToClass(connectionID, connectionClass);


   // Add chance for another connection in 2 team games.
   // The more players, the less the chance
   bool secondConnectionExists = false;
   float secondConnectionChance = rmRandFloat(0.0, 1.0);
   if(cNumberTeams < 3)
   {
       // TODO: Is there no logical and operator?
      if(cNumberNonGaiaPlayers < 4)
      {
         if(secondConnectionChance < 0.8)
            secondConnectionExists = true;
      }
      else
      {
         if(secondConnectionChance < 0.6)
           secondConnectionExists = true;
      }
   }

   rmEchoInfo("secondConnectionChance "+secondConnectionChance+ " secondConnectionExists "+secondConnectionExists);

   if(secondConnectionExists)
   {
      int alternateConnection=rmCreateConnection("alternate passes");
      rmAddConnectionTerrainReplacement(alternateConnection, CLIFFNORSEA, SNOWGRASS25);
      rmAddConnectionTerrainReplacement(alternateConnection, CLIFFNORSEB, SNOWGRASS25);
      rmAddConnectionTerrainReplacement(alternateConnection, CLIFFNORSEA, SNOWGRASS25);
      rmSetConnectionType(alternateConnection, cConnectAreas, false, 1.0);
      rmSetConnectionWarnFailure(alternateConnection, false);
      rmSetConnectionWidth(alternateConnection, connectionWidth, 4);
      rmSetConnectionTerrainCost(alternateConnection, CLIFFNORSEA, 5.0);
      rmSetConnectionTerrainCost(alternateConnection, CLIFFNORSEB, 3.0);
      rmAddConnectionStartConstraint(alternateConnection, connectionEdgeConstraint);
      rmAddConnectionEndConstraint(alternateConnection, connectionEdgeConstraint);
      rmAddConnectionStartConstraint(alternateConnection, playerConstraint);
      rmAddConnectionEndConstraint(alternateConnection, playerConstraint);

      rmSetConnectionPositionVariance(alternateConnection, -1.0);
/*         rmSetConnectionPositionVariance(alternateConnection, 50); */
      rmSetConnectionBaseHeight(alternateConnection, 0.0);
      rmSetConnectionHeightBlend(alternateConnection, 2);
      rmAddConnectionToClass(alternateConnection, connectionClass);
   }

   // Build team areas.
   int teamEdgeConstraint=rmCreateBoxConstraint("team edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
   float teamPercentArea = 0.80/cNumberTeams;
   if(cNumberNonGaiaPlayers < 4)
      teamPercentArea = 0.75/cNumberTeams;

   float percentPerPlayer = 0.75/cNumberNonGaiaPlayers;
   float teamSize = 0;


   for(i=0; <cNumberTeams)
   {
      // Create an area for the team
      int teamID=rmCreateArea("team"+i);
      rmSetTeamArea(i, teamID);
      teamSize = percentPerPlayer * rmGetNumberPlayersOnTeam(i);
      rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
/*      rmSetAreaSize(teamID, teamPercentArea, teamPercentArea); */
      rmSetAreaWarnFailure(teamID, false);
      rmSetAreaTerrainType(teamID, SNOWGRASS25);
      rmAddAreaTerrainLayer(teamID, CLIFFNORSEB, 2, 6);
      rmAddAreaTerrainLayer(teamID, CLIFFNORSEA, 0, 2);
      rmSetAreaMinBlobs(teamID, 1);
      rmSetAreaMaxBlobs(teamID, 5);
      rmSetAreaMinBlobDistance(teamID, 16.0);
      rmSetAreaMaxBlobDistance(teamID, 40.0);
      rmSetAreaCoherence(teamID, 0.0);
      rmSetAreaSmoothDistance(teamID, 10);
      rmAddAreaToClass(teamID, teamClass);
      rmSetAreaBaseHeight(teamID, 0.0);
      rmSetAreaHeightBlend(teamID, 2);
      rmAddAreaConstraint(teamID, teamConstraint);
      rmAddAreaConstraint(teamID, teamEdgeConstraint);
      rmSetAreaLocTeam(teamID, i);
      // Be sure that any two players on a team are connected
      // together
      rmAddConnectionArea(connectionID, teamID);
      if(secondConnectionExists)
         rmAddConnectionArea(alternateConnection, teamID);
      rmEchoInfo("Team area"+i);
   }

   // initial dress up of mountains
   int patchConstraint=rmCreateClassDistanceConstraint("patch vs patch", patchClass, 10);
   int failCount = 0;
   for(j=0; < cNumberNonGaiaPlayers*60)
   {
      int rockPatch = rmCreateArea("rock patch"+j);
      rmSetAreaSize(rockPatch, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(rockPatch, false);
/*      rmSetAreaBaseHeight(rockPatch, rmRandFloat(12.0, 15.0)); */
      rmSetAreaBaseHeight(rockPatch, rmRandFloat(5.0, 9.0));
      rmSetAreaHeightBlend(rockPatch, 1);
      rmSetAreaTerrainType(rockPatch, CLIFFNORSEA);
      rmSetAreaMinBlobs(rockPatch, 1);
      rmSetAreaMaxBlobs(rockPatch, 3);
/*      rmAddAreaToClass(rockPatch, patchClass); */
/*      rmAddAreaConstraint(rockPatch, patchConstraint); */
      rmSetAreaMinBlobDistance(rockPatch, 5.0);
      rmSetAreaMaxBlobDistance(rockPatch, 5.0);
      rmSetAreaCoherence(rockPatch, 0.3);
      if(rmBuildArea(rockPatch)==false)
         {
            // Stop trying once we fail 3 times in a row.
            failCount++;
            if(failCount==3)
               break;
         }
         else
            failCount=0;
   }

   // Place players.
   rmBuildAllAreas();
   rmBuildConnection(connectionID);
   if(secondConnectionExists)
      rmBuildConnection(alternateConnection);

   // Set up player areas.
   rmSetTeamSpacingModifier(0.75);
   float playerFraction=rmAreaTilesToFraction(2500);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
      rmEchoInfo("Player"+i+"team"+rmGetPlayerTeam(i));

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);

      rmAddAreaToClass(id, classPlayer);
      rmSetAreaWarnFailure(id, false);

      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
      rmSetAreaCoherence(id, 0.0);

      // Add constraints.
      rmAddAreaConstraint(id, playerConstraint);
      rmAddAreaConstraint(id, shortAvoidImpassableLand);

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Set type.
      rmSetAreaTerrainType(id, SNOWGRASS25);
      rmAddAreaTerrainLayer(id, SNOWGRASS25, 4, 12);
      rmAddAreaTerrainLayer(id, SNOWGRASS25, 0, 4);

   }

   // Build the areas.
   rmBuildAllAreas();

  for(i=1; <cNumberPlayers)
   {
      for(j=0; <3)
      {
         // Beautification sub area.
         int id3=rmCreateArea("snow patch"+i +j, rmAreaID("player"+i));
         rmSetAreaSize(id3, rmAreaTilesToFraction(10), rmAreaTilesToFraction(80));
         rmSetAreaWarnFailure(id3, false);
         rmSetAreaTerrainType(id3, SNOWGRASS25);
         rmAddAreaConstraint(id3, shortAvoidImpassableLand);
         rmSetAreaMinBlobs(id3, 1);
         rmSetAreaMaxBlobs(id3, 5);
         rmSetAreaMinBlobDistance(id3, 5.0);
         rmSetAreaMaxBlobDistance(id3, 20.0);
         rmSetAreaCoherence(id3, 0.0);

         rmBuildArea(id3);
      }
   }


   // For each player,
   for(i=1; <cNumberPlayers)
   {
      // TODO Why only up to 2 times?
      for(j=0; <3)
      {
         // Beautification sub area.
         // int rmCreateArea(string areaName, type?(rmAreaID) areaID)
         // creates a logical area that can be operated on
         // returns an area id
         int id2=rmCreateArea("grass patch"+i +j, rmAreaID("player"+i));
         // void rmSetAreaSize(int areaID, float minFraction, float maxFraction)
         // Set the area size to a min / max fraction of the map
         rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
         // void setAreaWarnFailure(int areaID, bool warn)
         // Turns warning on decoration failure through logging on
         rmSetAreaWarnFailure(id2, false);
         // void rmAreaTerrainType(int areaID, string terrain)
         // Sets the area terrain type, but perhaps not the actual decoration?
         rmSetAreaTerrainType(id2, SNOWGRASS25);
         // void rmAddAreaTerrainLayer(int areaID, string terrain, int TODO, int TODO)
         // Perhaps sets the actual decoration?
         rmAddAreaTerrainLayer(id2, SNOWGRASS25, 0, 2);
         rmAddAreaConstraint(id2, shortAvoidImpassableLand);
         rmSetAreaMinBlobs(id2, 1);
         rmSetAreaMaxBlobs(id2, 5);
         rmSetAreaMinBlobDistance(id2, 5.0);
         rmSetAreaMaxBlobDistance(id2, 20.0);
         rmSetAreaCoherence(id2, 0.0);

         rmBuildArea(id2);
      }
   }


   // Text
   rmSetStatusText("",0.60);

   // Place starting settlements.
   // Close things....
   // TC
   // Place object definition per player
   // Apparently has default third argument long placeCount=1
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Slight Elev.
   int numTries=10*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   failCount=0;

   numTries=8*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(1.0, 3.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, shortAvoidImpassableLand);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 10 times in a row.
         failCount++;
         if(failCount==10)
            break;
      }
      else
         failCount=0;
   }


   // Settlements.
   // int rmAddFairLoc(
   //    string unitName,
   //    bool forward,
   //    bool inside,
   //    float minPlayerDist,
   //    float maxPlayerDist,
   //    float locDist,
   //    float edgeDist,
   //    bool playerArea,
   //    bool teamArea
   // )
   id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 10, false, true); /* bool forward bool inside */
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);

   id=rmAddFairLoc("Settlement", true, true, 60, 90, 40, 10, false, true);
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
         {
            int settleArea = rmCreateArea("settlement area"+i +j, rmAreaID("Player"+i));
            rmSetAreaTerrainType(settleArea, "SnowA");
            rmSetAreaLocation(settleArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
            rmBuildArea(settleArea);
            rmPlaceObjectDefAtAreaLoc(id, i, settleArea);
         }
      }
   }


   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

   // Text
   rmSetStatusText("",0.80);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Cows
   rmPlaceObjectDefPerPlayer(closeCowsID, true);

   // Chickens, berries, or both ( if they hit the dice roll right ! )
   float startingFoodChance = rmRandFloat(0.0, 1.0);
   for(i=1; <cNumberPlayers)
   {
      if(startingFoodChance < 0.5)
      {
         rmPlaceObjectDefAtLoc(closeChickensID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
         if (startingFoodChance > 0.45)
         {
             rmPlaceObjectDefAtLoc(closeBerriesID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
         }
      }
      else
      {
         rmPlaceObjectDefAtLoc(closeBerriesID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
         if (startingFoodChance > 0.95)
         {
             rmPlaceObjectDefAtLoc(closeChickensID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
         }
      }
   }


   // Close hunted
   rmPlaceObjectDefPerPlayer(closeHuntableID, false);


   // Player forests
   int classForest=rmDefineClass("forest");
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", startingSettlementClassID, 20.0);

   for(i=0; <cNumberTeams)
   {
      failCount=0;
      int forestCount=rmRandInt(4, 5)*rmGetNumberPlayersOnTeam(i);
      for(j=0; <forestCount)
      {
         int forestID=rmCreateArea("team"+i+"forest"+j, rmAreaID("team"+i));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(140), rmAreaTilesToFraction(200));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "pine forest");
         rmAddAreaConstraint(forestID, forestSettleConstraint);
         rmAddAreaConstraint(forestID, forestObjConstraint);
         rmAddAreaConstraint(forestID, forestConstraint);
         rmAddAreaConstraint(forestID, avoidImpassableLand);
         rmAddAreaToClass(forestID, classForest);

         rmSetAreaMinBlobs(forestID, 2);
         rmSetAreaMaxBlobs(forestID, 2);
         rmSetAreaMinBlobDistance(forestID, 5.0);
         rmSetAreaMaxBlobDistance(forestID, 5.0);
         rmSetAreaCoherence(forestID, 0.5);

         if(rmBuildArea(forestID)==false)
         {
            // Stop trying once we fail 5 times in a row.
            failCount++;
            if(failCount==5)
               break;
         }
         else
            failCount=0;
      }
   }

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   // Deer
   rmPlaceObjectDefPerPlayer(mediumDeerID, false);

   // Far things.

   // Gold.
   int goldNum=rmRandInt(2, 4);
   rmEchoInfo("goldNum="+goldNum);
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(farGoldID, i, rmAreaID("team"+rmGetPlayerTeam(i)), goldNum);
      rmEchoInfo("far gold for"+i);
   }

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

   // Cows.
   rmPlaceObjectDefPerPlayer(farCowsID, false, 1);

   // Bonus huntable stuff.
   rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 1);

   rmPlaceObjectDefPerPlayer(bonusHuntableID2, false, 1);


   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

   rmPlaceObjectDefPerPlayer(farPredator2ID, false, 1);

   // Relics
   for(i=1; <cNumberPlayers)
   rmPlaceObjectDefInArea (relicID, i, rmAreaID("team"+rmGetPlayerTeam(i)), 1);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

   // rocks
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock granite sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   //rmAddObjectDefConstraint(rockID, avoidRock);
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 40*cNumberNonGaiaPlayers);

    // rocks
   int rockID2=rmCreateObjectDef("rock 2");
   rmAddObjectDefItem(rockID2, "rock granite big", 3, 1.0);
   rmAddObjectDefItem(rockID2, "rock granite small", 3, 3.0);
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 2, 3.0);
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 1, 5.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmAddObjectDefConstraint(rockID2, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidBuildings);
   rmAddObjectDefConstraint(rockID2, connectionConstraint);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   for(i=1; <cNumberNonGaiaPlayers*6)
   {
      if(rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 1)==0)
      {
         break;
      }
   }

   int rockID4=rmCreateObjectDef("rock 3");
   rmAddObjectDefItem(rockID4, "rock river icy", 1, 2.0);
   rmAddObjectDefItem(rockID4, "rock granite small", 2, 5.0);
   rmAddObjectDefItem(rockID4, "rock limestone sprite", 3, 5.0);
   rmSetObjectDefMinDistance(rockID4, 0.0);
   rmAddObjectDefConstraint(rockID4, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(rockID4, avoidAll);
   rmAddObjectDefConstraint(rockID4, avoidBuildings);
   rmAddObjectDefConstraint(rockID4, connectionConstraint);
   rmSetObjectDefMaxDistance(rockID4, rmXFractionToMeters(0.5));
   for(i=1; <cNumberNonGaiaPlayers*3)
   {
      if(rmPlaceObjectDefAtLoc(rockID4, 0, 0.5, 0.5, 1)==0)
      {
         break;
      }
   }

  // Text
   rmSetStatusText("",1.0);

}
