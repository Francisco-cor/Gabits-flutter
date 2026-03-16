import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gabits/services/database_service.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Isar isarInstance(IsarInstanceRef ref) => DatabaseService.instance;
