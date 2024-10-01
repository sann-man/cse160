#include "../../includes/packet.h"

module FloodingP {
    provides interface Flooding;
}

implementation {
    command void Flooding.pass() {
        // Dummy implementation
    }
}




// module FloodingP {
//     provides interface Flooding;
//     uses interface timer<TMilli> as FloodingTimer; 
//     uses interface SimpleSend as Sender; 
// }

// implementation {
//     pack sendPackage; 
    
//     command void Flooding.pass() {
//         // Dummy implementation
//     }
// }
