// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';


contract FlightSuretyApp {
    IFlightSuretyData iFlightSuretyData;
    
    address flightSuretyDataAddress;
    
    address contractOwner;
    

  
  constructor(address _flightSuretyDataAddress) {
      contractOwner = msg.sender;
      flightSuretyDataAddress = _flightSuretyDataAddress;
      iFlightSuretyData = IFlightSuretyData(_flightSuretyDataAddress);
    
  }
  
    /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
/********************************************************************************************/

    
    
    function registerAirline(address _account, uint8 _state) public {
        iFlightSuretyData.updateAirlineStatus(_account, _state);
    }
    
    function startAirlineApplication(string memory _name) public {
        iFlightSuretyData.createNewAirline(_name, msg.sender);
        
    }
    
    
  /********************************************************************************************/
  /*                                       UTILITY FUNCTIONS                                 */
  /********************************************************************************************/
    
      function getOwner() external view returns(address) {
        return contractOwner;
      }
      
      
      
      
    
    
    
    

}





interface IFlightSuretyData {
    function createNewAirline(string memory _name, address _account) external;
    
    function updateAirlineStatus(address _account, uint8 _state) external;
    // function _onlyAuthorizedAirlines() external view;
    
}


