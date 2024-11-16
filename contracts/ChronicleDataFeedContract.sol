// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title MultiOracleReader
 * @notice A contract to read from multiple Chronicle oracles on Sepolia testnet
 * @dev This contract is specifically designed for Sepolia testnet with chainId 11155111
 */
contract ChronicleDataFeedContract {
    // Sepolia chain ID
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    
    // SelfKisser address on Sepolia
    address private constant SELF_KISSER_ADDRESS = 0x0Dcc19657007713483A5cA76e6A7bbe5f56EA37d;

    // Struct to store oracle information
    struct OracleInfo {
        string symbol;
        address oracleAddress;
        bool isInitialized;
    }

    // Mapping from symbol to oracle information
    mapping(string => OracleInfo) public oracles;
    
    // Array to store all supported symbols
    string[] public supportedSymbols;

    // The SelfKisser contract for granting access
    ISelfKisser public immutable selfKisser;

    // Events
    event OracleAdded(string symbol, address oracleAddress);
    event PriceRead(string symbol, uint256 price, uint256 age);

    constructor() {
        // Ensure we're on Sepolia testnet
        require(block.chainid == SEPOLIA_CHAIN_ID, "This contract must be deployed on Sepolia testnet");
        
        selfKisser = ISelfKisser(SELF_KISSER_ADDRESS);
        
        // Initialize all Sepolia testnet oracle addresses
        _addOracle("AAVE/USD", 0x3F982a82B4B6bd09b1DAF832140F166b595FEF7F);
        _addOracle("ARB/USD", 0x9Bf0C1ba75C9d7b6Bf051cc7f7dCC7bfE5274302);
        _addOracle("AVAX/USD", 0x7F56CdaAdB1c5230Fcab3E20D3A15BDE26cb6C2b);
        _addOracle("BNB/USD", 0xE4A1EED38F972d05794C740Eae965A7Daa6Ab28c);
        _addOracle("BTC/USD", 0x6edF073c4Bd934d3916AA6dDAC4255ccB2b7c0f0);
        _addOracle("CRVUSD/USD", 0x3de6bEc5d5FE063fB23F36E363182AB353AbC56E);
        _addOracle("CRV/USD", 0xDcda58cAAC639C20aed270859109f03E9832a13A);
        _addOracle("DAI/USD", 0xaf900d10f197762794C41dac395C5b8112eD13E1);
        _addOracle("ETHX/USD", 0xc6639C0591d632Bf689ceab617A0377072e7f524);
        _addOracle("ETH/BTC", 0xf95d3B8Ae567F4AA9BEC822931976c117cdf836a);
        _addOracle("ETH/USD", 0xdd6D76262Fd7BdDe428dcfCd94386EbAe0151603);
        _addOracle("GNO/USD", 0x9C9e56AE479f82bcF229F2200420106C93C0A24e);
        _addOracle("IBTA/USD", 0x92b7Ab73BA53Bc64b57194242e3a36A6F1209A70);
        _addOracle("LDO/USD", 0x4cD2a8c3Fd6329029461A95784051A553f31eb29);
        _addOracle("LINK/USD", 0x260c182f0054BF244a8e38d7C475b6d9f67AeAc1);
        _addOracle("MKR/USD", 0xE55afC31AFA140597c581Bc32057BF393ba97c5A);
        _addOracle("MNT/USD", 0x90f13128715157f6f2708b3e379a345a330C598c);
        _addOracle("OP/USD", 0x1Be54a524226fc44565747FE221157f4cAE71B80);
        _addOracle("POL/USD", 0x98AF7A50F7478eac901B7d00d0C28Ec2C9cc65b9);
        _addOracle("RETH/ETH", 0xAE888F70d319d9ab9318B2326AEf97Bde2c1F96f);
        _addOracle("RETH/USD", 0x6454753E0909E7F6476BfB78BD6BDC281197A5be);
        _addOracle("SDAI/DAI", 0x0B20Fd1c09452FC3F214667073EA8975aB2c55EA);
        _addOracle("SD/USD", 0x0939F04AbA985E3861C4D7AD9fbD66b976Dd47a8);
        _addOracle("SNX/USD", 0x1eFD788C634C59e2c7507b523B3eEfD6CaaE0c4f);
        _addOracle("SOL/USD", 0x39eC7D193D1Aa282b8ecCAC9B791b09c75D30491);
        _addOracle("UNI/USD", 0x0E9e54244F6585a71d0d1035E7625849B516C817);
        _addOracle("USDC/USD", 0xb34d784dc8E7cD240Fe1F318e282dFdD13C389AC);
        _addOracle("USDM/USD", 0xe971B2aF139Ad803656533059Bc028b61C00F67F);
        _addOracle("USDT/USD", 0x8c852EEC6ae356FeDf5d7b824E254f7d94Ac6824);
        _addOracle("WBTC/USD", 0xdc3ef3E31AdAe791d9D5054B575f7396851Fa432);
        _addOracle("WSTETH/ETH", 0x2d95B1862279771fcE76823CD777384D8598fB48);
        _addOracle("WSTETH/USD", 0x89822dd9D74dF50BFba8764DC9bE25E9B8d554A1);
        _addOracle("WUSDM/USDM", 0xF719E362724Dda4Ad3B8D92D49E0c44E48Df4e56);
        _addOracle("WUSDM/USD", 0x6d10de3640ab2F11B1102Ae72C06BB497E5E859b);
        _addOracle("YFI/USD", 0xdF54aBf0eF88aB7fFf22e21eDD9AE1DA89A7DefC);

        // Self kiss all oracles
        for (uint i = 0; i < supportedSymbols.length; i++) {
            selfKisser.selfKiss(oracles[supportedSymbols[i]].oracleAddress);
        }
    }

    /**
     * @notice Internal function to add an oracle
     * @param symbol The trading pair symbol
     * @param oracleAddress The address of the oracle on Sepolia
     */
    function _addOracle(string memory symbol, address oracleAddress) internal {
        require(!oracles[symbol].isInitialized, "Oracle already initialized");
        require(oracleAddress != address(0), "Invalid oracle address");
        
        oracles[symbol] = OracleInfo({
            symbol: symbol,
            oracleAddress: oracleAddress,
            isInitialized: true
        });
        supportedSymbols.push(symbol);
        
        emit OracleAdded(symbol, oracleAddress);
    }

    // Add this state variable after the existing mappings in ChronicleDataFeedContract
    mapping(string => uint256) public lastAccessTime;

    /**
     * @notice Read the latest price for a specific trading pair
     * @param symbol The trading pair symbol (e.g., "ETH/USD")
     * @return price The current price with 18 decimals
     * @return age The timestamp of the last update
     */
    function readPrice(string memory symbol) public returns (uint256 price, uint256 age) {
        require(oracles[symbol].isInitialized, "Oracle not found");
        
        IChronicle oracle = IChronicle(oracles[symbol].oracleAddress);
        (price, age) = oracle.readWithAge();
        
        // Emit event can't be done in view function, but would be useful in non-view functions
        // emit PriceRead(symbol, price, age);

        // Track access time
        lastAccessTime[symbol] = block.timestamp;
        emit PriceRead(symbol, price, age);
        
        
        return (price, age);
    }

    // Add this getter function
    function getLastAccessTime(string memory symbol) external view returns (uint256) {
        require(oracles[symbol].isInitialized, "Oracle not found");
        return lastAccessTime[symbol];
    }

    /**
     * @notice Read the latest prices for multiple trading pairs
     * @param symbols Array of trading pair symbols to read
     * @return prices Array of current prices with 18 decimals
     * @return ages Array of timestamps for the last updates
     */
    function readMultiplePrices(string[] calldata symbols) 
        external 
       
        returns (uint256[] memory prices, uint256[] memory ages) 
    {
        uint256 length = symbols.length;
        prices = new uint256[](length);
        ages = new uint256[](length);

        for (uint i = 0; i < length; i++) {
            (prices[i], ages[i]) = readPrice(symbols[i]);
        }

        return (prices, ages);
    }

    /**
     * @notice Read the latest prices for all supported trading pairs
     * @return symbols Array of trading pair symbols
     * @return prices Array of current prices with 18 decimals
     * @return ages Array of timestamps for the last updates
     */
    function readAllPrices() external returns (
        string[] memory symbols,
        uint256[] memory prices,
        uint256[] memory ages
    ) {
        uint256 length = supportedSymbols.length;
        symbols = supportedSymbols;
        prices = new uint256[](length);
        ages = new uint256[](length);

        for (uint i = 0; i < length; i++) {
            (prices[i], ages[i]) = readPrice(supportedSymbols[i]);
        }

        return (symbols, prices, ages);
    }

    /**
     * @notice Get all supported trading pairs
     * @return Array of supported symbols
     */
    function getSupportedSymbols() external view returns (string[] memory) {
        return supportedSymbols;
    }

    /**
     * @notice Check if a symbol is supported
     * @param symbol The trading pair symbol to check
     * @return bool True if the symbol is supported
     */
    function isSymbolSupported(string memory symbol) external view returns (bool) {
        return oracles[symbol].isInitialized;
    }

    /**
     * @notice Get the oracle address for a specific symbol
     * @param symbol The trading pair symbol
     * @return The oracle address on Sepolia
     */
    function getOracleAddress(string memory symbol) external view returns (address) {
        require(oracles[symbol].isInitialized, "Oracle not found");
        return oracles[symbol].oracleAddress;
    }
}

interface IChronicle {
    function read() external view returns (uint256 value);
    function readWithAge() external view returns (uint256 value, uint256 age);
}

interface ISelfKisser {
    function selfKiss(address oracle) external;
}