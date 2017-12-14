pragma solidity ^0.4.18;

import "./Gifto.sol";

contract User {
    event Deposit(address, uint256);
    event SendETH(address, uint256);
    Gifto gifto;
    function User(Gifto _gifto){
        gifto = _gifto;
    }
    
    function()
    payable
    external{
        
    }
    function deposit()
    payable
    public{
        Deposit(msg.sender, msg.value);
    }
    
    function do_Transfer(address to, uint256 amount)
    external 
    returns(bool){
        return gifto.transfer(to, amount);
    }
    
    function sendETHtoGifto()
    external
    returns(bool)
    {
        SendETH(address(gifto), this.balance);
        return gifto.send(this.balance);
    }
}

contract TestGifto{
    event CoinCreation(address Wallet);
    event coin(address, uint256);
    event logger(string, string);
    Gifto gifto;
    
    address public addr_1 = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    address public addr_2 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    address public addr_3 = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
    address public addr_4 = 0x583031d1113ad414f02576bd6afabfb302140225;
    address public addr_5 = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
    
    address[] investorList = [addr_1, addr_2, addr_3];
    address[] nonInvestorList = [addr_4, addr_5];

    function createGifto() 
    public {
        gifto = new Gifto();
        CoinCreation(address(gifto));
    }
    
    function test_turnOnSale()
    public{
        gifto.turnOnSale();
        bool _selling = gifto._selling();
        
        //selling should be true after turn on
        if(_selling == true){
            logger("selling: True", "PASS TEST");
        }
        else{
            logger("selling: False", "FAILED TEST");
        }
    }
    
    function test_turnOffSale()
    public {
        gifto.turnOffSale();
        bool _selling = gifto._selling();
        
        //selling should be FALSE after turn off
        if(_selling == false){
            logger("selling: False", "PASS TEST");
        }
        else{
            logger("selling: True", "FAILED TEST");
        }
    }
    
    function test_sendTransaction()
    external {
        User user1 = new User(gifto);
        User user2 = new User(gifto);

        uint256 amount = 5000000000000;
        // init Gifto from owner for user 1, 5000000000000 unit
        gifto.transfer(address(user1), amount);
        
        user1.do_Transfer(address(user2), amount);
    }
    
    function test_transferWithoutTradable()
    public {
        if (gifto.tradable() == true){
            logger("tradable is true now", "try another test");
            return;
        }
        // test: transfer with amount > user1's balances
        logger("test: transfer without tradable, SHOULD NOT done", "START TEST");
        // call low level function to control revert
        // this is data for "test_sendTransaction()"
        bytes32 data = 0x30ea0352;
        
        // SHOULD NOT be done
        if (this.call(data)){
            logger("test: transfer success", "FAILED TEST");
        }
        else{
            logger("test: transfer failed", "PASS TEST");
        }
    }
    
    function test_tranferWithTradable()
    public{
        if (gifto.tradable() == false){
            logger("tradable is false now, DO TURN ON\n NOTE: you should test functions with tradable is off before this test", "PREPAIR TEST");
            gifto.turnOnTradable();
        }
        //recheck
        if (gifto.tradable() == false){
            logger("recheck: tradable is false now, check turnOnTradable function", "try another test");
            return;
        }

        User user1 = new User(gifto);
        User user2 = new User(gifto);
        // init Gifto from owner for user 1, 5000000000000 unit
        logger("init amount for user 1", "PREPAIR");
        gifto.transfer(address(user1), 5000000000000);
        
        // test 1: transfer with amount > user1's balances
        logger("test 1: transfer with amount > user1's balances, SHOULD NOT done", "START TEST");
        if (user1.do_Transfer(address(user2), 6000000000000) == false){
            logger("test 1: transfer failed", "PASS TEST");
        }
        else{
            logger("test 1: transfer success", "FAILED TEST");
        }
        
        // test 2: transfer with amount <= user1's balances
        logger("test 2: transfer with amount < user1's balances, SHOULD done", "START TEST");
        if (user1.do_Transfer(address(user2), 3000000000000) == true){
            logger("test 2: transfer success", "PASS TEST");
        }
        else {
            logger("test 2: transfer ", "FAILED TEST");
        }
    }
    
    function test_transferFromOwner_WithoutTradable() 
    public {
        if(this != gifto.owner()){
            logger("this is not call from owner", "try another test");
            return;
        }
        if (gifto.tradable() == true){
            logger("tradable is true now, can't turn off tradable", "try another test");
            return;
        }
        // create tmp user
        User tmp = new User(gifto);
        // init amount 200,000,000,00000
        uint256 amount = 20000000000000;
        // do transfer from owner 200,000,000,00000 to user tmp
        gifto.transfer(address(tmp), amount);
        
        // check the balance of user tmp mapping with amount
        uint256 balanceOfUser = gifto.balanceOf(address(tmp));
        
        // checking test
        if (balanceOfUser == amount){
            logger("amount of new user is mapped exactly", "PASS TEST");
        }
        else {
            logger("amount of new user is not mapped", "FAILED TEST");
        }
    }
    
    function test_addInvestor() 
    public {
        gifto.addInvestorList(investorList);

        // test investor is in the list
        bool testInInvestorListResult = true;
        
        for (uint256 i = 0; i < investorList.length; i++) {
            if (gifto.isApprovedInvestor(investorList[i]) == false) {
                testInInvestorListResult = false;
                break;
            }
        }
        
        if (testInInvestorListResult == true) {
            logger("all added investors are in approved investors list", "PASS TEST");
        }
        else {
            logger("at least on added investor is not in approved investors list", "FAILED TEST");
        }

        // test non-investor is in the list
        bool testNotInInvestorListResult = true;
        
        for (i = 0; i < nonInvestorList.length; i++) {
            if (gifto.isApprovedInvestor(nonInvestorList[i]) == true) {
                testNotInInvestorListResult = false;
                break;
            }
        }
        
        if (testInInvestorListResult == true && testNotInInvestorListResult == true) {
            logger("add approved investors list", "PASS TEST");
        }
        else {
            logger("add approved investors list", "FAILED TEST");
        }

    }
    
    function test_turnOnTradable() 
    public{
        logger("test: turn on tradable", "START");
        gifto.turnOnTradable();
        bool tradable = gifto.tradable();

        // tradable should be true after turning it ON
        if(tradable == true){
            logger("tradable: true", "TEST PASSED");
        }
        else{
            logger("tradable: false", "TEST FAILED");
        }

    }
    
    function test_setPrice()
    public {
        gifto = new Gifto();
        CoinCreation(address(gifto));

        uint256 newPrice = 45 * 10**17;
        
        // consider to use the value computed from external source, should not from our code
        uint256 expected_originalBuyPrice = newPrice;
        uint256 expected_maximumBuy = 10**18 * 10000000000 / newPrice;
        
        gifto.setBuyPrice(newPrice);
        
        uint256 new_originalBuyPrice = gifto._originalBuyPrice();
        uint256 new_maximumBuy = gifto._maximumBuy();
        
        if (new_originalBuyPrice == expected_originalBuyPrice && 
            new_maximumBuy == expected_maximumBuy) {
            logger("set new buy price", "TEST PASSED");
        }
        else {
            logger("set new buy price", "TEST FAILED");
        }
    }

    
    
    function allTest(){
        createGifto();
        test_turnOffSale();
        test_setPrice();
        test_turnOnSale();
        test_transferFromOwner_WithoutTradable();
        test_transferWithoutTradable();
        test_tranferWithTradable();
    }
}