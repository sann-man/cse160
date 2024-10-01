/*
 * ANDES Lab - University of California, Merced
 * This class provides the basic functions of a network node.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 *
 */
#include <Timer.h>
#include "includes/command.h"
#include "includes/packet.h"
#include "includes/CommandMsg.h"
#include "includes/sendInfo.h"
#include "includes/channels.h"
#include "includes/NeighborTable.h"

module Node{
   uses interface Boot;

   uses interface SplitControl as AMControl;
   uses interface Receive;

   uses interface SimpleSend as Sender;

   uses interface CommandHandler;

   uses interface NeighborDiscovery; 
   uses interface Flooding; 
}

implementation{
   pack sendPackage;

   // Prototypes
   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t Protocol, uint16_t seq, uint8_t *payload, uint8_t length);

   event void Boot.booted(){
      call AMControl.start();

      // booted 
      // dbg(GENERAL_CHANNEL, "Booted\n");

      // neighbor discovery start 
      if (call NeighborDiscovery.start() == SUCCESS) { 
         dbg(NEIGHBOR_CHANNEL, "NeighborDiscovery start command was successful.\n");
      } 
      else {
        dbg(NEIGHBOR_CHANNEL, "NeighborDiscovery start command failed.\n");
      }
      
   }

   event void AMControl.startDone(error_t err){
      if(err == SUCCESS){
         // radio on
         // dbg(GENERAL_CHANNEL, "Radio On\n");
      }else{
         //Retry until successful
         call AMControl.start();
      }
   }

   event void AMControl.stopDone(error_t err){}

   // event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
   //    dbg(GENERAL_CHANNEL, "Packet Received\n");
   //    if(len==sizeof(pack)){
   //       // to get packet structure 
   //       pack* myMsg=(pack*) payload;
   //       dbg(GENERAL_CHANNEL, "Package Payload: %s\n", myMsg->payload);
   //       return msg;
   //    }
   //    dbg(GENERAL_CHANNEL, "Unknown Packet Type %d\n", len);
   //    return msg;
   // }

   // ------ Neighbor Discovery ---------- // 
   // Received Request packet
   // Send reply packet 
   neighbor_t neighborTable[MAX_NEIGHBORS];
   uint8_t count = 0;  // Keep track of the number of neighbors

   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
      pack* myMsg = (pack*) payload; 
      uint8_t i; 

      if (myMsg->type == TYPE_REPLY) {
         dbg(GENERAL_CHANNEL, "Received Reply payload: %s from %d\n", myMsg->payload, myMsg->src);

         call NeighborDiscovery.handleNeighbor(myMsg->src, 100);

         // iterate the neighbor table to find the matching neighbor
         // for (i = 0; i < count; i++) {
         //       if (neighborTable[i].neighborID == myMsg->src) {
         //          neighborTable[i].received++;
         //          dbg(NEIGHBOR_CHANNEL, "Updated packets received for Neighbor %d: %d\n", myMsg->src, neighborTable[i].received);
         //          break; // Exit loop once the neighbor is found
         //       }
         // }
      }

      if (myMsg->type == TYPE_REQUEST) {
         dbg(GENERAL_CHANNEL, "Received request payload %s from %d\n", myMsg -> payload, myMsg->src);

         sendPackage.src = TOS_NODE_ID; 
         sendPackage.dest = myMsg->src; 
         sendPackage.type = TYPE_REPLY; 
         sendPackage.seq = myMsg->seq; 
         sendPackage.protocol = PROTOCOL_PING; 
         memcpy(sendPackage.payload, "REPLY", 8); 

         if (call Sender.send(sendPackage, myMsg->src) == SUCCESS) { 
               dbg(GENERAL_CHANNEL, "Reply message sent from %d from seq: %d\n", myMsg->src, sendPackage.seq);
         } else { 
               dbg(GENERAL_CHANNEL, "Reply message failed to send, node may be inactive\n"); 
         }

         // for (i = 0; i < count; i++) { 
         //       if (neighborTable[i].neighborID == myMsg->src) { 
         //          neighborTable[i].sent++; 
         //          dbg(NEIGHBOR_CHANNEL, "Updated sent count for Neighbor %d: %d\n", myMsg->src, neighborTable[i].sent);
         //          break; 
         //       }
         // }

         // Handle neighbor information
         call NeighborDiscovery.handleNeighbor(myMsg->src, 100);
      }

      return msg;
   }


   event void CommandHandler.ping(uint16_t destination, uint8_t *payload){
      dbg(GENERAL_CHANNEL, "PING EVENT \n");
      makePack(&sendPackage, TOS_NODE_ID, destination, 0, 0, 0, payload, PACKET_MAX_PAYLOAD_SIZE);
      call Sender.send(sendPackage, destination);
   }

   event void CommandHandler.printNeighbors(){}

   event void CommandHandler.printRouteTable(){}

   event void CommandHandler.printLinkState(){}

   event void CommandHandler.printDistanceVector(){}

   event void CommandHandler.setTestServer(){}

   event void CommandHandler.setTestClient(){}

   event void CommandHandler.setAppServer(){}

   event void CommandHandler.setAppClient(){}

   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
      Package->src = src;
      Package->dest = dest;
      Package->TTL = TTL;
      Package->seq = seq;
      Package->protocol = protocol;
      memcpy(Package->payload, payload, length);
   }
}
