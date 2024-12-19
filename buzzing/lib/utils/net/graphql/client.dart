import 'package:buzzing/common/utils/common_utils.dart';
import 'package:graphql/client.dart';

Future<GraphQLClient> _client(token) async {
  final HttpLink _httpLink = HttpLink('');
  final AuthLink _authLink = AuthLink(getToken: () => '$token');

  final Link _link = _authLink.concat(_httpLink);
  var path = await CommonUtils.getApplicationDocumentsPath();
  final store = await HiveStore.open(path: path);
  return GraphQLClient(link: _link, cache: GraphQLCache(store: store));
}

GraphQLClient? _innerClient;

initClient(token) async {
  _innerClient ??= await _client(token);
}

releaseClient() {
  _innerClient = null;
}
