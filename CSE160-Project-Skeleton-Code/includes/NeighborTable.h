#ifndef NEIGHBOR_TABLE_H
#define NEIGHBOR_TABLE_H

#define MAX_NEIGHBORS 20 // Max number of neighbors to track
#define ACTIVE 1
#define INACTIVE 0

// Define the structure for neighbor information
typedef struct {
    uint16_t neighborID;  // ID of the neighbor
    uint8_t linkQuality;  // TPR / TRS
    uint16_t isActive;  
    uint16_t lastSeen; 
    // uint8_t sent; 
    // uint8_t recieved;

} neighbor_t;

// Function prototypes
void addNeighbor(neighbor_t* table, uint8_t* count, uint16_t id, uint8_t quality);
void checkActivity(neighbor_t* table, uint8_t* count); 
// void removeNeighbor(neighbor_t* table, uint8_t* count, uint16_t id);

#endif // NEIGHBOR_TABLE_H
