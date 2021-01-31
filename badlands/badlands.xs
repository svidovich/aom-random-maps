string SANDA = "SandA";

void main(void) {
    int playerTiles = 10000;
    if ( cMapSize == 1 )
    {
        // Large map chosen
        playerTiles = 14040;
    }
    int size = 2.0 * sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
    rmSetMapSize(size, size);
    rmSetSeaLevel(-20);
    rmTerrainInitialize(SANDA);

    rmSetLightingSet("anatolia");

    // Define this now so that we can get the ID dynamically later.
    int classCliff = rmDefineClass("cliff");

    int avoidAll = rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
    int avoidBuildings = rmCreateTypeDistanceConstraint("avoid buildings", "Building", 8.0);
    int farAvoidImpassableLand = rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 16.0);
    int selfCliffConstraint = rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 16.0);


    // Cliffage
    int numTries = 6 * cNumberNonGaiaPlayers;
    int cliffBuildFailCount = 0;
    for(i = 0; < numTries)
    {
        int cliffID = rmCreateArea("cliff"+i);
        rmSetAreaWarnFailure(cliffID, false);
        rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
        rmSetAreaCliffType(cliffID, "Egyptian");
        rmAddAreaConstraint(cliffID, selfCliffConstraint);
        rmAddAreaToClass(cliffID, classCliff);

        rmAddAreaConstraint(cliffID, avoidBuildings);
        rmAddAreaConstraint(cliffID, farAvoidImpassableLand);
        rmAddAreaConstraint(cliffID, avoidAll);

        rmSetAreaMinBlobs(cliffID, 50);
        rmSetAreaMaxBlobs(cliffID, 120);

        // rmSetAreaCliffEdge(int areaID, int count, float size, float variance, float spacing, int mapEdge)
        rmSetAreaCliffEdge(cliffID, 8, 12.0, 4.0, 1.0, 0);
        // rmSetAreaCliffPainting(int areaID, bool paintGround, bool paintOutsideEdge, bool paintSide, float minSideHeight, bool paintInsideEdge)
        rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, true);
        rmSetAreaCliffHeight(cliffID, 12, 1.0, 1.0);

        rmSetAreaMinBlobDistance(cliffID, 4.0);
        rmSetAreaMaxBlobDistance(cliffID, 24.0);

        rmSetAreaCoherence(cliffID, 0.25);
        rmSetAreaSmoothDistance(cliffID, 10);
        rmSetAreaHeightBlend(cliffID, 8);

        if(rmBuildArea(cliffID)==false)
        {
            // Stop trying once we fail 3 times in a row.
            cliffBuildFailCount++;
            if(cliffBuildFailCount == 3)
            {
                break;
            }
        }
        else
        {
           cliffBuildFailCount = 0;
        }
    }
}