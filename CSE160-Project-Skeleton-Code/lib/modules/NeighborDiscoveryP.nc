#include "../../includes/packet.h"
#include "../../includes/channels.h"
#include "../../includes/NeighborTable.h"


module NeighborDiscoveryP {
    provides interface NeighborDiscovery;
    uses interface Timer<TMilli> as NeighborDiscoveryTimer;
    uses interface SimpleSend as Sender;
}

implementation {
    
    // Packet of type pack from packet.h
    pack sendPackage; 

    // sequence number
    uint16_t seqNum = 0; 

    // Neighbor table declaration and count of neighbors
    neighbor_t neighborTable[MAX_NEIGHBORS]; 
    uint8_t count = 0;

    // ---------- Start ------------- // 
    // Start discovery process 
    bool neighborDiscoveryStarted = FALSE; 
    command error_t NeighborDiscovery.start() {
        neighborDiscoveryStarted = TRUE; 
        dbg(NEIGHBOR_CHANNEL, "NeighborDiscovery started\n");
        
        call NeighborDiscoveryTimer.startPeriodic(5000); 
        
        return SUCCESS; 
    }

    // ----- Timer fired ---  // 
    event void NeighborDiscoveryTimer.fired() {
        dbg(NEIGHBOR_CHANNEL, "Sending request package\n");
        
        // from package header 
        // |
        // v
        sendPackage.src = TOS_NODE_ID;
        sendPackage.dest = AM_BROADCAST_ADDR;
        // sequence number incremented in the SimpleSendP
        sendPackage.seq = seqNum++;
        sendPackage.TTL = 0;
        sendPackage.type = TYPE_REQUEST; 
        sendPackage.protocol = PROTOCOL_PING;
        memcpy(sendPackage.payload, "REQUEST", 8);

        // increment sent from NeighborTable
        // Send the package
        // ...
        if (call Sender.send(sendPackage, AM_BROADCAST_ADDR) == SUCCESS) {
            dbg(NEIGHBOR_CHANNEL, "Request package sent from seq: %d\n", sendPackage.seq);

        } else {
            dbg(NEIGHBOR_CHANNEL, "Failed to send package\n");
        }
        
        // neighborTable[].sent++; 
        // dbg(NEIGHBOR_CHANNEL, "Sent %d", neighborTable.sent); 

        // get rid of debug commands
        // call Sender.send(sendPackage, AM_BROADCAST_ADDR); 
    } 

    //  ----------- Neighbor table functionality  ------------------- //
    // Use Node.nc to handle receiving functionality but other functionality will remain here
    // |-> better for modularity 
    void addNeighbor(neighbor_t* table, uint8_t* countPtr, uint16_t id, uint8_t quality) {
        // Check if neighbor already exists
        uint8_t i; 

        for (i = 0; i < *countPtr; i++) { 
            if (table[i].neighborID == id) { 
                // update existing neighbor info
                table[i].linkQuality = quality; 
                table[i].isActive = ACTIVE; 
                table[i].lastSeen = 0; 
                return; 
            }
        }
        
        // check if the table is full
        if (*countPtr < MAX_NEIGHBORS) {
            // add new neighbor at the next available slot
            table[*countPtr].neighborID = id;
            table[*countPtr].linkQuality = quality;
            table[*countPtr].isActive = ACTIVE;
            table[*countPtr].lastSeen = 0;
            (*countPtr)++;
            dbg(NEIGHBOR_CHANNEL, "Neighbor added: ID = %d, Quality = %d\n", id, quality); 
        } else { 
            // ff table is full check for inactive neighbors 
            for (i = 0; i < *countPtr; i++) {
                if (table[i].isActive == INACTIVE) {
                    table[i].neighborID = id; 
                    table[i].linkQuality = quality; 
                    table[i].isActive = ACTIVE;
                    table[i].lastSeen = 0;
                    dbg(NEIGHBOR_CHANNEL, "Inactive neighbor switched with ID = %d\n", id);
                    return;
                }
            }
            dbg(NEIGHBOR_CHANNEL, "Neighbor table is full, and no inactive neighbors found\n");
        }
    }

    // Check if neighbor is INACTIVE
    // Nieghbor can be dead or link is gone ... 
    void checkActivity(neighbor_t* table, uint8_t *countPtr){ 
        uint8_t i; 
        for (i = 0; i < *countPtr; i++){ 
            if(table[i].isActive == INACTIVE){ 
                table[i].lastSeen++;  

                if(table[i].lastSeen > 5) { 
                    table[i].isActive = INACTIVE; 
                    // 
                    dbg(NEIGHBOR_CHANNEL, "Node %d has been set as inActive", table[i].isActive); 
                }
            }
        }
    }

    // ------- Remove neighbors that are no longer active  -----------//
    // marks the neighbor as inactive 

    // dont need if neighbor is already set inActive by checkActivity function

    // void removeNeighbor(neighbor_t* table, uint8_t* countPtr, uint16_t id){
    //     uint8_t i = 0; 
    //     for(i = 0; i < *countPtr; i++){ 
    //         if(table[i].isActive == INACTIVE){ 
    //             // table[i].isActive = INACTIVE;  
    //             dbg(NEIGHBOR_CHANNEL, "Neighbor %d removed from ACTIVE list",id); 
    //             return; 
    //         }
    //     }
    // }

    command void NeighborDiscovery.handleNeighbor(uint16_t id, uint8_t quality) {
        // call the addNeighbor function 
        addNeighbor(neighborTable, &count, id, quality); 
        checkActivity(neighborTable, &count); 
        // removeNeighbor(neighborTable, &count, id); 
        
    }



}