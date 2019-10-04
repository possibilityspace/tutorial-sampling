
int CODE_BLOCK = 2;
int CODE_GROUND = 1;
int CODE_START = 10;
int CODE_END = 11;
int CODE_ENEMY = 4;
int CODE_CRATE = 3;

float CHANCE_SPAWN_ENEMY = 0.05;
float CHANCE_SPAWN_POWERUP = 0.2;
float CHANCE_TO_ADD_GAP = 0.2;
float CHANCE_TO_CHANGE_HEIGHT = 0.4;
float CHANCE_FOR_FLOATING_BLOCK = 0.2;
float CHANCE_LARGE_HEIGHT_CHANGE = 0.1;

int MIN_BLOCK_SPACE = 4;

int MIN_GAP_SIZE = 3;
int MAX_GAP_SIZE = 8;

int borderGuaranteedGround = 4;
int maxGapHalfSize = 2;
int forcedGroundHalfSize = 4;

//Inspired by the LinearLevelGenerator from the Mario AI framework 
//https://github.com/amidos2006/Mario-AI-Framework/blob/e26d568960840b63a40a1902204e20b8b04fef39/src/levelGenerators/linear/LevelGenerator.java
int[][] GenerateLinearLevel(){
  int[][] level = new int[levelWidth][levelHeight];
  
  int gapTiles = 0;
  int groundHeight = 3;
  
  int forcedGround = 0;
  
  int[] groundPoints = new int[levelWidth];
  
  for(int c=0; c<levelWidth; c++){
    
     if(forcedGround > 0 || c < borderGuaranteedGround || c > levelWidth-borderGuaranteedGround || gapTiles == 0){
       if(forcedGround > 0){
         forcedGround--;
       }
       if(c == 1){
          level[c][levelHeight-groundHeight-1] =  CODE_START;
       }
       if(c == levelWidth-2){
          level[c][levelHeight-groundHeight-1] =  CODE_END;
       }
       
       //Whatever the base ground height is, add tiles to that height
       for(int j=levelHeight-1; j> levelHeight-groundHeight-1; j--){
          level[c][j] = 1; 
       }
       
       groundPoints[c] = groundHeight+1;
       
       if(c % 2 == 0 && random(1) < CHANCE_TO_CHANGE_HEIGHT){
              if(random(1) > CHANCE_LARGE_HEIGHT_CHANGE){
                if(groundHeight > 1 && random(1) > 0.5){
                     groundHeight--;
                }
                else if(groundHeight < levelHeight/2){
                     groundHeight++; 
                }
              }
              else{
                if(groundHeight > 2 && random(1) > 0.5){
                     groundHeight -= 2;
                }
                else if(groundHeight < levelHeight/2){
                     groundHeight += 2; 
                }
              }
           }
       
       if(forcedGround == 0 && c > borderGuaranteedGround && c <= levelWidth-borderGuaranteedGround){
           if(random(1) < CHANCE_TO_ADD_GAP){
             gapTiles = MIN_GAP_SIZE + (int)random(MAX_GAP_SIZE - MIN_GAP_SIZE);
           }
       }       
     }
     else if(gapTiles > 0){
        gapTiles -= 1; 
        if(gapTiles == 0){
           forcedGround = forcedGroundHalfSize + (int)random(forcedGroundHalfSize);
        }
     }
   }
   
   for(int i=borderGuaranteedGround; i<groundPoints.length-1-borderGuaranteedGround; i++){
      if(groundPoints[i] > 0 && groundPoints[i] == groundPoints[i+1]){
        //Find the length of this run of space
        int runLength = 0;
        for(int j=i; j<groundPoints.length-borderGuaranteedGround; j++){
          if(groundPoints[j] == groundPoints[i])
            runLength++;
          else
            break;
        }
        //We can place things here!
        if(runLength > MIN_BLOCK_SPACE){
          //float roll = random(1);
           //if(roll < CHANCE_SPAWN_POWERUP){
            i += PlaceBlocks(i, levelHeight-groundPoints[i]-1, level, runLength);
          //}
          //switch((int)random(2)){
             //case 0:
               
             //  break;
             //case 1:
               
             //  break;
          //}
        }
      }
      else if(groundPoints[i] == 0){
         if(random(1) < CHANCE_FOR_FLOATING_BLOCK){
           if(random(1) < CHANCE_SPAWN_POWERUP)
              level[i][7] = CODE_BLOCK;
            else
              level[i][7] = CODE_CRATE; 
         }
      }
   }
   
   for(int i=0; i<level.length; i++){
     for(int j=0; j<level[i].length-1; j++){
      if(level[i][j] == 0 && 
      (level[i][j+1] == CODE_GROUND || level[i][j+1] == CODE_BLOCK || level[i][j+1] == CODE_CRATE)){
         if(random(1) < CHANCE_SPAWN_ENEMY){
           int enemyType = (int)(random(2));
             if(enemyType == 0){
                 level[i][j] = CODE_ENEMY;
             }
             else{
               level[i][j] = CODE_ENEMY;
             }
         }
      }
     }
   }
   
   return level;
}

//if(roll < CHANCE_SPAWN_ENEMY){
//             i += PlaceEnemies(i, levelHeight-groundPoints[i]-1, level, runLength); 
//          }
//          else

int MAX_BLOCK_SEGMENT_LENGTH = 6;

public int PlaceBlocks(int x, int y, int[][] level, int runLength){
  runLength = min(runLength, MAX_BLOCK_SEGMENT_LENGTH);
  
   for(int i=0; i<runLength/2; i++){
     int blockType = CODE_CRATE;
     if(random(1) < 0.2)
       blockType = 0;
     else if(random(1) < CHANCE_SPAWN_POWERUP)
        blockType = CODE_BLOCK;
       
     level[x+i][y-1] = blockType;
     level[x+runLength-i-1][y-1] = blockType;
   }
   
   if(runLength % 2 != 0){
     int blockType = CODE_CRATE;
     if(random(1) < CHANCE_SPAWN_POWERUP)
        blockType = CODE_BLOCK;
     level[x+runLength/2][y-1] = blockType;
   }
   
   if(runLength > 2 && y > 4){
      PlaceBlocks(x+1, y-3, level, runLength-2);
   }
   
   return runLength;
}

int MAX_ENEMIES_IN_A_ROW = 3;
int ENEMY_SPACING = 1;

public int PlaceEnemies(int x, int y, int[][] level, int runLength){
  
    int maxRunSize = MAX_ENEMIES_IN_A_ROW;
    if(ENEMY_SPACING > 0){
       maxRunSize += (maxRunSize-1)*ENEMY_SPACING; 
    }
    int runSize = 1 + (int)random(min(runLength-1, maxRunSize));
    
    int placement_x = (int)random(runLength - runSize);
    int enemyType = (int)random(2);
  
    int count = 0;
    for(int i=placement_x; i<runSize; i++){
      if(ENEMY_SPACING > 0 && count++ == ENEMY_SPACING){
        count = 0;
        continue;
      }
      
       if(enemyType == 0){
           level[x+i][y+1] = CODE_ENEMY;
       }
       else{
         level[x+i][y-1] = CODE_ENEMY;
       }
       
       
       
    }
    return runSize;
}
