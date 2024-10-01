#include "../../includes/am_types.h"

configuration FloodingC {
    provides interface Flooding;
}

implementation {
    components FloodingP, NeighborDiscoveryC as Neigh;
    components new SimpleSendC(AM_PACK);  

    Flooding = FloodingP.Flooding;
    FloodingP.Neigh -> Neigh.NeighborDiscovery;

    FloodingP.Flooder -> SimpleSendC;

    // You can remove ReceiveC wiring if not explicitly required.
}
