import JSONBig from 'json-bigint';

const parser = JSONBig({ storeAsString: true, strict: true });

export function parseJson(text) {
  return parser.parse(text);
}
