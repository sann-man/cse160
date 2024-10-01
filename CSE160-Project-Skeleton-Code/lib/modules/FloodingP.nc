#include "../../includes/packet.h"
#include "../../includes/channels.h"
#include "../../includes/NeighborTable.h"
#include "../../includes/sendInfo.h"
#include "../../includes/am_types.h"
#include "../../includes/protocol.h"

module FloodingP {
    provides interface Flooding;

    uses interface SimpleSend as Flooder;

    uses interface Receive as Receiver;

    uses interface NeighborDiscovery as Neigh;

    


}

implementation {
    pack sendFlood;
    uint16_t sequenceNum = 0;

    neighbor_t neighborTable[MAX_NEIGHBORS]; 


    command void Flooding.pass() {
        // Dummy implementation
        // uint8_t i;
        // for (i = 0; i < MAX_NEIGHBORS; i++){
        //     neighborTable[i] = neighborDiscovery.getNeighbor()
        // }
    }

    uint16_t finalDestination = 10; 
    command error_t Flooding.start(){
        dbg(FLOODING_CHANNEL, "flooding started\n"); 
        call Neigh.getNeighbor(neighborTable); //I want to get neighbor table to use 

        sendFlood.src = TOS_NODE_ID; 
        sendFlood.seq = sequenceNum; 
        sendFlood.fdest = finalDestination; 
        sendFlood.TTL = 20; 
        sendFlood.type = TYPE_F; 
        sendFlood.protocol = PROTOCOL_PING; 
        memcpy(sendFlood.payload, "Flooding message", 20); 
        dbg(FLOODING_CHANNEL, "this is the destination node %d\n", sendFlood.fdest); 
        return SUCCESS;
    }

    

    command error_t Flooding.send(pack msg, uint16_t dest) {
        uint8_t nid;
        uint8_t i;

        nid = neighborTable[i].neighborID;

        if(call Flooder.send(msg, nid) == SUCCESS){
            dbg(FLOODING_CHANNEL, "Unicast Sent Successfully\n");
            return SUCCESS; 
        } else {
            dbg(FLOODING_CHANNEL, "Unicast Sent Failed\n");
            return FAIL;
        }
    }


    event message_t* Receiver.receive(message_t* msg, void* payload, uint8_t len){

        // pack* myMsg = (pack*) payload;
        // if (myMsg->dest ==)
        // //check to see if its a duplicase
        // //if not, add to cache
        // //then unicast to its neighbor
        //     sendFlood.src -> TOS_NODE_ID;
        //     sendFlood.dest -> myMsg->src;
        //     sendFlood.TTL -> MAX_TTL;
        //     sendFlood.seq -> sequenceNum;
        //     sendFlood.protocol->PROTOCOL_PING;
            
    }


    void neighborFlood(uint8_t nodeID) { 
        uint8_t i = 0; 
        for(i = 0; i < MAX_NEIGHBORS; i++){
            if (neighborTable[i].neighborID == nodeID) { 
                dbg(FLOODING_CHANNEL, "Forwarding message to neighbor %d\n", neighborTable[i].neighborID);
                call Flooder.send(sendFlood, neighborTable[i].neighborID); 
            }
        }
    }
}
