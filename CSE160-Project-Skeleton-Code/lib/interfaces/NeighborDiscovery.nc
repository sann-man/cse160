interface NeighborDiscovery {
    command error_t start();
    command void checkStartStatus();  
    command void handleNeighbor(uint16_t id, uint8_t quality); 
}
