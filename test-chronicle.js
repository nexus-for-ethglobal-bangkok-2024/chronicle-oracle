const { ethers} = require("ethers");

require('dotenv').config();

// Contract ABI - Including only the methods we'll test
const contractABI = [
    "function readPrice(string) view returns (uint256, uint256)",
    "function readMultiplePrices(string[]) view returns (uint256[], uint256[])",
    "function readAllPrices() view returns (string[], uint256[], uint256[])",
    "function getSupportedSymbols() view returns (string[])",
    "function isSymbolSupported(string) view returns (bool)",
    "function getOracleAddress(string) view returns (address)",
    "function getLastAccessTime(string) view returns (uint256)", 
    "function lastAccessTime(string) view returns (uint256)",  
    "event OracleAdded(string symbol, address oracleAddress)",
    "event PriceRead(string symbol, uint256 price, uint256 age)"
];

// Configuration
const config = {
    contractAddress: "0xEe1495A54c077811f626a6B369832094689f07AE",
    sepoliaRPC: process.env.ALCHEMY_TESTNET_RPC_URL,
    privateKey: process.env.TESTNET_PRIVATE_KEY,
};

async function main() {
    // Connect to Sepolia network
    const provider = new ethers.providers.JsonRpcProvider(config.sepoliaRPC);
    const wallet = new ethers.Wallet(config.privateKey, provider);
    const contract = new ethers.Contract(config.contractAddress, contractABI, wallet);

    try {
        console.log('Starting Chronicle Data Feed Contract Tests...\n');

        // 1. Get all supported symbols
        console.log('1. Getting supported symbols...');
        const symbols = await contract.getSupportedSymbols();
        console.log(`Supported symbols: ${symbols.slice(0, 5)}... (${symbols.length} total)\n`);

        // 2. Test reading single price
        console.log('2. Testing single price read for ETH/USD...');
        const [price, age] = await contract.readPrice('ETH/USD');
        console.log(`ETH/USD Price: $${ethers.utils.formatUnits(price, 18)}`);
        console.log(`Last updated: ${new Date(age * 1000).toLocaleString()}\n`);

        // 3. Test reading multiple prices
        console.log('3. Testing multiple price read...');
        const symbolsToTest = [
            // 'BTC/USD', 'ETH/USD', 'LINK/USD', 
            "AAVE/USD",
    "ARB/USD",
    "AVAX/USD",
    "BNB/USD",
    "BTC/USD",
    "CRVUSD/USD",
    "CRV/USD",
    "DAI/USD",
    "ETHX/USD",
    "ETH/BTC",
    "ETH/USD",
    "GNO/USD",
    "IBTA/USD",
    "LDO/USD",
    "LINK/USD",
    "MKR/USD",
    "MNT/USD",
    "OP/USD",
    "POL/USD",
    "RETH/ETH",
    "RETH/USD",
    "SDAI/DAI",
    "SD/USD",
    "SNX/USD",
    "SOL/USD",
    "UNI/USD",
    "USDC/USD",
    "USDM/USD",
    "USDT/USD",
    "WBTC/USD",
    "WSTETH/ETH",
    "WSTETH/USD",
    "WUSDM/USDM",
    "WUSDM/USD",
    "YFI/USD"
        ];
        const [prices, ages] = await contract.readMultiplePrices(symbolsToTest);
        symbolsToTest.forEach((symbol, i) => {
            console.log(`${symbol} Price: $${ethers.utils.formatUnits(prices[i], 18)}`);
            console.log(`Last updated: ${new Date(ages[i] * 1000).toLocaleString()}`);
        });
        console.log();

        // 4. Test symbol support check
        console.log('4. Testing symbol support check...');
        const isEthSupported = await contract.isSymbolSupported('ETH/USD');
        const invalidSymbol = await contract.isSymbolSupported('INVALID/PAIR');
        console.log(`Is ETH/USD supported? ${isEthSupported}`);
        console.log(`Is INVALID/PAIR supported? ${invalidSymbol}\n`);

        // 5. Get oracle address
        console.log('5. Getting oracle address for ETH/USD...');
        const ethOracleAddress = await contract.getOracleAddress('ETH/USD');
        console.log(`ETH/USD Oracle Address: ${ethOracleAddress}\n`);

        // 6. Read all prices
        console.log('6. Reading all prices...');
        const [allSymbols, allPrices, allAges] = await contract.readAllPrices();
        console.log(`Retrieved prices for ${allSymbols.length} pairs`);
        // Display first 3 prices as sample
        for (let i = 0; i < 20; i++) {
            console.log(`${allSymbols[i]}: $${ethers.utils.formatUnits(allPrices[i], 18)}`);
        }
        console.log('...');

        // 7. Set up event listener
        console.log('\n7. Setting up event listener for PriceRead events (will run for 60 seconds)...');
        contract.on('PriceRead', (symbol, price, age, event) => {
            console.log(`\nPrice Read Event Detected:`);
            console.log(`Symbol: ${symbol}`);
            console.log(`Price: $${ethers.utils.formatUnits(price, 18)}`);
            console.log(`Age: ${new Date(age * 1000).toLocaleString()}`);
        });

        // Keep the script running for 60 seconds to listen for events
        await new Promise(resolve => setTimeout(resolve, 60000));
        
        // Remove the event listener
        contract.removeAllListeners();

        // Add this test after your existing tests
        console.log('8. Testing state change with lastAccessTime...');
        // First read will update the state
        const readResult = await contract.readPrice('ETH/USD');
        console.log(`Price read completed for ETH/USD`);

        // Get the last access time
        const lastAccess = await contract.getLastAccessTime('ETH/USD');
        console.log(`Last access time for ETH/USD: ${new Date(lastAccess * 1000).toLocaleString()}\n`);
        
    } catch (error) {
        console.error('Error:', error);
    }
}

// Create .env file with following variables:
// SEPOLIA_RPC_URL=your_alchemy_sepolia_rpc_url
// PRIVATE_KEY=your_wallet_private_key

main().catch(console.error);