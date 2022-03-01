import 'package:flutter_riverpod/flutter_riverpod.dart';

enum STATE { NORMAL, PICKED, UPLOAD, SUCCESS, ERROR }

final uploadState = StateProvider((ref) => STATE.NORMAL);