/// This is a redirector so that people can continue, in google3, to depend on
/// the transformer as -intl, not needing to change it to intl_translation.
//
// Note that this is not exported into the opensource version, and would not
// work there, since it depends on a library not in ourpubspec. It is a complete
// hack and google3 specific. Fortunately, transformers in general are
// deprecated so it should go away soon.

// TODO(alanknight): Remove this.
library transformer_forwarder;

export 'package:intl_translation/transformer.dart';