import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crypto/data/repo/wallet_connector.dart';
import 'package:http/http.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:walletconnect_qrcode_modal_dart/walletconnect_qrcode_modal_dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WalletConnectEthereumCredentials extends CustomTransactionSender {
  WalletConnectEthereumCredentials({required this.provider});

  final EthereumWalletConnectProvider provider;

  @override
  Future<EthereumAddress> extractAddress() {
    throw UnimplementedError();
  }

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final hash = await provider.sendTransaction(
      from: transaction.from!.hex,
      to: transaction.to?.hex,
      data: transaction.data,
      gas: transaction.maxGas,
      gasPrice: transaction.gasPrice?.getInWei,
      value: transaction.value?.getInWei,
      nonce: transaction.nonce,
    );

    return hash;
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    throw UnimplementedError();
  }

  @override
  // TODO: implement address
  EthereumAddress get address => throw UnimplementedError();

  @override
  MsgSignature signToEcSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToEcSignature
    throw UnimplementedError();
  }
}

class EthereumConnector implements WalletConnector {
  late final WalletConnectQrCodeModal _connector;
  late final EthereumWalletConnectProvider _provider;

  EthereumConnector() {
    _connector = WalletConnectQrCodeModal(
      connector: WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        clientMeta: const PeerMeta(
          name: 'Demo ETH',
          description: 'Demo ETH Application',
          url: 'https://walletconnect.org',
          icons: [
            'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ],
        ),
      ),
    );

    _provider = EthereumWalletConnectProvider(_connector.connector);
  }

  @override
  Future<SessionStatus?> connect(BuildContext context) async {
    return await _connector.connect(context, chainId: 1);
  }

  @override
  void registerListeners(
    OnConnectRequest? onConnect,
    OnSessionUpdate? onSessionUpdate,
    OnDisconnect? onDisconnect,
  ) =>
      _connector.registerListeners(
        onConnect: onConnect,
        onSessionUpdate: onSessionUpdate,
        onDisconnect: onDisconnect,
      );

  @override
  Future<String?> sendAmount({
    required String recipientAddress,
    required double amount,
  }) async {
    print("test");
    print(_connector.connector.session.accounts[0]);
    final sender =
        EthereumAddress.fromHex(_connector.connector.session.accounts[0]);
    final recipient =
        EthereumAddress.fromHex("0xa154d2a02181942aAfDEEC87B04c4cF60e49B04b");
    print(recipient);
    print(recipientAddress);

    final etherAmount = BigInt.two;
    // EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.one);
    DeployedContract contract = await loadContract(
        abiFileName: "assets/abi1.json",
        contractAdd: '"0x39F8B9F624D36aeEC009F5497edB9eE9bCB63a0D"');
    final ethFunction = contract.function("transfer");

    final transaction = Transaction.callContract(
        from: sender,
        contract: contract,
        function: ethFunction,
        parameters: [recipient, etherAmount]);
    final credentials = WalletConnectEthereumCredentials(provider: _provider);
    var result = await _ethereum.sendTransaction(credentials, transaction);
    print(result);
    return result;
  }

  @override
  Future<String?> mintNFT
    ({
      required String recipientAddress,
      required double amount,
    }) async {
    print("test");
    print(_connector.connector.session.accounts[0]);
    final sender =
        EthereumAddress.fromHex(_connector.connector.session.accounts[0]);
    final to =
        EthereumAddress.fromHex("0xa154d2a02181942aAfDEEC87B04c4cF60e49B04b");

    // final etherAmount = BigInt.two;
    DeployedContract contract = await loadContract(
        abiFileName: "assets/abi.json",
        contractAdd: '0xa7F227731658F6f3F3Ab0Da9ad35C283d485Dae2');
    final ethFunction = contract.function("safeMint");

    final kind = BigInt.zero;
    final batchId = BigInt.zero;
    final tierId = BigInt.zero;
    final amount = BigInt.zero;
    final mintAmount = BigInt.one;
    // const uri = "QmdXC7M3A7N8d7BkfB6aP2wBZcwTUnHXF8k4gvTM667wfp";
    // const uri = "QmaggZKtGDYbs6XykKADzYnNB85eSGeztfrzaxLwHYNCSV";
    // const uri = "QmVbpBFAa8EXqzqRiujGzND9eYptf5DFA64KXJnVawHdMs ";
    // const uri = "QmTQnqcNWp8gf2a9Us3SVQmGVuhZZFLqWvFd3E9YQek5oh ";
    const uri = "QmSUHU4kigU8PmwQYJTxydLbDRggoaRp9XsLFDMZLg6vkK";
    final swapToken =
        EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");
    final target =
        EthereumAddress.fromHex("0xa7F227731658F6f3F3Ab0Da9ad35C283d485Dae2");
    const proof = [];
    final Object assets = [
      kind,
      batchId,
      tierId,
      amount,
      mintAmount,
      uri,
      swapToken,
      to,
      target,
      proof
    ];
    print(assets);
    final transaction = Transaction.callContract(
        from: sender,
        // gasPrice: EtherAmount.inWei(BigInt.one),
        // maxGas: 100000,
        // value: etherAmount,
        contract: contract,
        function: ethFunction,
        parameters: [assets]);
    final credentials = WalletConnectEthereumCredentials(provider: _provider);


    var result = await _ethereum.sendTransaction(credentials, transaction);
    print(result);
    return result;
  }

  @override
  Future<void> openWalletApp() async => await _connector.openWalletApp();

  @override
  Future<double> getBalance() async {
    final address =
        EthereumAddress.fromHex(_connector.connector.session.accounts[0]);
    final amount = await _ethereum.getBalance(address);
    return amount.getValueInUnit(EtherUnit.ether).toDouble();
  }

  Future<DeployedContract> loadContract(
      {required String abiFileName, required String contractAdd}) async {
    String abi = await rootBundle.loadString(abiFileName);
    String contractAddress = contractAdd;

    final contract = DeployedContract(ContractAbi.fromJson(abi, "ERC20"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  @override
  bool validateAddress({required String address}) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  String get faucetUrl => 'https://faucet.dimensions.network/';

  @override
  String get address => _connector.connector.session.accounts[0];

  @override
  String get coinName => 'MATIC';

  final _ethereum = Web3Client(
      'https://polygon-mumbai.g.alchemy.com/v2/gjTUrSBNjwTwjF6P8L6hM_UFeuSZob70',
      Client());
}
