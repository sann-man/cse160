#ifndef NEIGHBOR_TABLE_H
#define NEIGHBOR_TABLE_H

#include <stdint.h>

// Define constants
#define MAX_NEIGHBORS 20 // Maximum number of neighbors to track
#define ACTIVE 1
#define INACTIVE 0

// define the structure for neighbor information
typedef struct {
    uint16_t neighborID; 
    uint16_t linkQuality; 
    uint16_t isActive;     // Status of the link (ACTIVE/INACTIVE)
} neighbor_t;


void addNeighbor(neighbor_t* table, uint8_t* count, uint16_t id, uint8_t quality);
void removeNeighbor(neighbor_t* table, uint8_t* count, uint16_t id);
void get(neighbor_t* table, uint8_t* count);

#endif 
