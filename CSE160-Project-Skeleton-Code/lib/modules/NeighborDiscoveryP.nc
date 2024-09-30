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
        
        call NeighborDiscoveryTimer.startPeriodic(50000); 
        return SUCCESS; 
    }

    // ----- Timer fired ---  // 
    event void NeighborDiscoveryTimer.fired() {
        dbg(NEIGHBOR_CHANNEL, "Sending request package\n");
        
        // Prepare HELLO message
        sendPackage.src = TOS_NODE_ID;
        sendPackage.dest = AM_BROADCAST_ADDR;
        // sequence number incremented in the SimpleSendP
        sendPackage.seq = seqNum++;
        sendPackage.TTL = 1;
        sendPackage.type = TYPE_REQUEST; 
        sendPackage.protocol = PROTOCOL_PING;
        memcpy(sendPackage.payload, "GOLD", 6);

        // Send the package
        if (call Sender.send(sendPackage, AM_BROADCAST_ADDR) == SUCCESS) {
            dbg(NEIGHBOR_CHANNEL, "Request package sent successfully\n");
            dbg(NEIGHBOR_CHANNEL, "sequence number: %d\n", sendPackage.seq); 
        } else {
            dbg(NEIGHBOR_CHANNEL, "Failed to send package\n");
        }
    } 

    command void NeighborDiscovery.checkStartStatus() {
        if (neighborDiscoveryStarted) {
            dbg(NEIGHBOR_CHANNEL, "NeighborDiscovery has been started.\n");  
        } else {
            dbg(NEIGHBOR_CHANNEL, "NeighborDiscovery has not been started.\n");
        }
    }

    //  ----------- Neighbor table functionality  ------------------- //
    // Use Node.nc to handle receiving functionality but other functionality will remain here
    // |-> better for modularity 
    void addNeighbor(neighbor_t* table, uint8_t* countPtr, uint16_t id, uint8_t quality) {
        // Check if neighbor already exists
        uint8_t i; 
        for (i = 0; i < *countPtr; i++) { 
            if (table[i].neighborID == id) { 
                table[i].neighborID = id;
                table[i].linkQuality = quality; 
                table[i].isActive = ACTIVE; 
                return; 
            }
        }

        // Add new neighbor if table is not yet full
        if (*countPtr < MAX_NEIGHBORS) {
            // Add new neighbor at the available slot
            table[*countPtr].neighborID = id;
            table[*countPtr].linkQuality = quality;
            table[*countPtr].isActive = ACTIVE;
            (*countPtr)++;
            dbg(NEIGHBOR_CHANNEL, "Neighbor added: ID = 0%d, Quality = %d\n", id, quality ); 
        } else { 
            dbg(NEIGHBOR_CHANNEL, "Neighbor table is full\n"); 
        }
    }

    // ------- Remove neighbors that are no longer active  -----------//
    // marks the neighbor as inactive 

    void removeNeighbor(neighbor_t* table, uint8_t* countPtr, uint16_t id){
        uint8_t i = 0; 
        for(i = 0; i < *countPtr; i++){ 
            if(table[i].isActive == INACTIVE){ 
                table[i].isActive = INACTIVE;  
                dbg(NEIGHBOR_CHANNEL, "Neighbor %d removed from ACTIVE list",id); 
                return; 
            }
        }
    }

    command void NeighborDiscovery.handleNeighbor(uint16_t id, uint8_t quality) {
        // call the addNeighbor function 
        addNeighbor(neighborTable, &count, id, quality); 
        removeNeighbor(neighborTable, &count, id); 
        
    }



}