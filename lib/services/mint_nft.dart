import 'dart:html';

import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';

// Future<DeployedC> loadContract() async {
//   String abi = await rootBundle.loadString('assets/abi.json');
// }
Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString("assets/abi.json");
  String contractAddress = "contractAddress1";

  final contract = DeployedContract(ContractAbi.fromJson(abi, "safeMint"),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

// Future<String> callFunction(String funcname, List<dynamic> args){
//   // Web3Client ethClient, string
//   final ethereum<String> = Web3Client(
//       'https://polygon-mumbai.g.alchemy.com/v2/gjTUrSBNjwTwjF6P8L6hM_UFeuSZob70',
//       Client());
// }



