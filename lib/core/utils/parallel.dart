/// 限制并发的映射执行（PRD §24.6：预览生成 / 元数据请求并发受限）。
Future<List<R>> mapLimited<T, R>(
  Iterable<T> items,
  int concurrency,
  Future<R> Function(T item) transform,
) async {
  final list = items.toList();
  if (list.isEmpty) return const [];
  final results = List<R?>.filled(list.length, null);
  var next = 0;
  final workers = List.generate(
    concurrency.clamp(1, list.length),
    (_) => Future(() async {
      while (true) {
        final i = next++;
        if (i >= list.length) break;
        results[i] = await transform(list[i]);
      }
    }),
  );
  await Future.wait(workers);
  return results.cast<R>();
}
