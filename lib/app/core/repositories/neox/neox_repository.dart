part of '../book_repository.dart';

class _NeoxRepository extends ILoadBook {
  _NeoxRepository() : super(index: 1, initialIndex: 1);

  @override
  Fonte get fonte => Fonte.NEOX_SCANS;

  static final _NeoxRepository _instance = _NeoxRepository();

  @override
  Future<Book> getBookByURL(String title) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    // Future<bool> loadData([bool isLoadMoreAction = false]) async {
    final now = DateTime.now();
    // print(_customDio.interceptors);
    if (isSuccess && _hasMore) index++;

    try {
      final subKey = 'page/$index/?s&post_type=wp-manga&m_orderby=${_type.order}';
      // final subKey = 'manga/page/${index ?? this.index}/?m_orderby=${type.order}';
      final String mainURL = '$baseURL/$subKey';
      final Response response = await _customDio.get(mainURL, responseType: ResponseType.plain);
      final Document document = parse(response.data);

      // final Element? element = document.querySelector('.wrap .tab-content-wrap .c-tabs-item');
      final elements = document.querySelectorAll('body .c-tabs-item__content');
      // final elements = document.querySelectorAll('body .page-item-detail');
      if (elements.isEmpty) return false;
      // if (element == null) return Result.success(false);

      for (final element in elements) {
        final ScrapingUtil scrapingUtil = ScrapingUtil(element);

        final String url = scrapingUtil.getURL(selector: 'h3 a');
        final double? score = scrapingUtil.getScore(selector: '.score.total_votes');
        final String title = scrapingUtil.getByText(selector: 'h3 a');
        final chapter = scrapingUtil.getByText(selector: '.latest-chap a').dataOrNull;
        final String? lastChapter = chapter != null ? 'Capítulo ${int.tryParse(chapter.replaceAll(RegExp(r'[^0-9]'), ''))}' : null;
        final String originalImage = scrapingUtil.getImage(selector: 'img');
        // if (type == TypeEvent.RELEASE) print([originalImage, title, url].hasEmpty);
        final String? bookType = scrapingUtil.getByText(selector: '.manga-title-badges').dataOrNull;
        final String? mediumImage = scrapingUtil.getImage(selector: 'img', bySrcSet: true, last: true).dataOrNull;
        final String? largeImage = scrapingUtil.getImage(selector: 'img', bySrcSet: true).dataOrNull;

        if ([url, title].hasEmpty) continue;

        List<Tags>? tags = scrapingUtil.getInfo<List<Tags>>(
          selector: '.post-content_item',
          whereTest: (element) => element.querySelector('.summary-heading h5')?.text.trim().toLowerCase() != 'genres',
          endReturn: (data) => data.split(',').map((e) => Tags(title: e.trim())).toList(),
        );

        if ([originalImage, title, url].hasEmpty) continue;

        final Book book = Book(
          id: url.urlToId,
          type: bookType,
          tags: tags,
          fonte: Fonte.NEOX_SCANS,
          url: url,
          lastChapter: lastChapter,
          originalImage: originalImage,
          largeImage: largeImage,
          mediumImage: mediumImage,
          title: title,
          score: score,
        );
        if (!contains(book)) add(book);
      }

      isSuccess = true;
      _hasMore = true;
      log('${DateTime.now().difference(now)}');
      return true;
    } on DioError catch (_, __) {
      isSuccess = false;
      _hasMore = false;
      log('Algo ruím aconteceu', error: _, stackTrace: __);
      return false;
    }
  }

  @override
  Future<Result<Book>> bookInfo(Book book) async {
    try {
      final now = DateTime.now();
      String mainURL = book.url;
      Response response;

      try {
        response = await _customDio.get(mainURL, responseType: ResponseType.plain);
      } on DioError catch (_, __) {
        final newURL = await getURLByTitle(book.title);
        if (newURL.isNotEmpty) {
          response = await _customDio.get(newURL, responseType: ResponseType.plain);
        } else {
          throw Exception();
        }
      }

      final Document document = parse(response.data);

      final List<Chapter> chapters = [];

      final ScrapingUtil scrapingUtil = ScrapingUtil.bySelector(document, selector: '.site-content');

      if (scrapingUtil.error) return Result.failure(Exception());

      // Categorias
      final List<Tags>? tags = scrapingUtil.getInfo<List<Tags>>(
        selector: '.genres-content a',
        initialData: book.tags,
        endFirstReturn: (element, initialData) {
          final List<Tags> temp = [...?initialData];
          for (var element in element) {
            final Tags tag = Tags(title: element.text.trim());
            if (tag.title.isNotEmpty && !temp.contains(tag)) temp.add(tag);
          }
          return temp;
        },
      );

      // Status
      String? status = scrapingUtil.getInfo<String>(
        selector: '.post-content_item',
        stringRemove: (remove) => 'status',
        endSelector: '.summary-content',
      );

      // Type
      String? type = scrapingUtil.getInfo<String>(
        selector: '.post-content_item',
        stringRemove: (remove) => 'tipo',
        endSelector: '.summary-content',
      );
      type ??= scrapingUtil.getByText(selector: '.post-title span');

      // Autor
      String? autor = scrapingUtil.getInfo<String>(
        selector: '.post-content_item',
        stringRemove: (remove) => 'autor',
        endSelector: '.summary-content',
      );

      double? score = scrapingUtil.getScore(selector: '.post-total-rating span');

      // Image
      final String? image = scrapingUtil.getImage(selector: '.summary_image img').dataOrNull;
      // final String? secondImage = scrapingUtil.getImage(selector: '.summary_image img', bySrcSet: true).dataOrNull;

      // Sinopse
      final String sinopse = scrapingUtil.getByText(selector: '.manga-excerpt');

      // Chapters
      List<Element> elements = scrapingUtil.element.querySelectorAll('.main li .wp-manga-chapter');
      if (elements.isEmpty) elements = scrapingUtil.element.querySelectorAll('.main li');
      for (final element in elements) {
        final ScrapingUtil scrapingUtil = ScrapingUtil(element);
        final String url = scrapingUtil.getURL(selector: 'a');

        final String? elementCreatedAt = scrapingUtil.createdAt();
        // String? chapterDescription;
        // double chapterNumber;
        String name =
            element.children.firstWhere((element) => element.localName?.contains('a') ?? element.localName?.contains('ul') ?? false).text.trim();

        // if ([type, title].isNM()) {
        //   if (name.contains('-')) chapterDescription = name.split('-').last.trim();
        //   chapterNumber = double.parse(name.split('-').first.trim().replaceAll(RegExp(r'((\+|-)?([^0-9]+)^(\.[0-9]+)?)|^^((\+|-)?\.?[^0-9]+)'), ''));
        //   name = name.split('-').first.trim();
        // } else {
        //   if (name.contains('-')) {
        //     chapterNumber =
        //         double.parse(name.split('-').first.trim().replaceAll(RegExp(r'((\+|-)?([^0-9]+)^(\.[0-9]+)?)|^^((\+|-)?\.?[^0-9]+)'), ''));
        //     chapterDescription = name.split('-').last.trim();
        //     name = name.split('-').first.trim();
        //   } else {
        //     chapterNumber = double.parse(name.trim().replaceAll(RegExp(r'((\+|-)?([^0-9]+)^(\.[0-9]+)?)|^^((\+|-)?\.?[^0-9]+)'), ''));
        //   }
        // }

        final (chapterDescription, chapterNumber, title, _, _) = DataParse.titleParse(name, type);

        if ([url, name].hasEmpty) continue;

        // log('chapterNumber: $chapterNumber\nname: $name\nchapterDescription: $chapterDescription');

        final chapter = Chapter(
          id: url.urlToId,
          chapterNumber: chapterNumber,
          chapterDescription: chapterDescription,
          fonte: Fonte.NEOX_SCANS,
          createdAt: ParseDateTime(data: elementCreatedAt).parse,
          url: url,
          chapterName: title,
        );

        if (!chapters.contains(chapter)) chapters.add(chapter);
      }

      final newBook = book.copyWith(
        originalImage: image,
        autor: autor,
        score: score,
        status: status,
        tags: tags,
        sinopse: DataParse.sinopseParse(sinopse),
        chapters: chapters.reversed.toList(),
        type: type,
      );

      log('${DateTime.now().difference(now)}');

      return Result.success(newBook);
    } on DioError catch (_, __) {
      log('Algo ruím aconteceu', error: _, stackTrace: __);
      return Result.failure(_);
    } on Exception catch (_, __) {
      log('Algo ruím aconteceu', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }

  // @override
  // Map<String, String> get _headers => {
  //       "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36",
  //     };

  @override
  Future<String> getURLByTitle(String title) async {
    try {
      const subKey = 'wp-admin/admin-ajax.php';
      // final subKey = 'manga/page/${index ?? this.index}/?m_orderby=${type.order}';
      final String mainURL = '$baseURL/$subKey';
      final Response response = await _customDio.post(
        mainURL,
        responseType: ResponseType.json,
        data: FormData.fromMap({
          'title': title.trim(),
          'action': 'wp-manga-search-manga',
        }),
      );
      final parseDate = (response.data['data'] as List<dynamic>).map((e) => Map.from(e)).toList();
      if (parseDate.any((element) => element.containsKey('error'))) return '';

      return parseDate.firstWhere((element) => (element['title'] as String).contains(title.trim()))['url'] as String;
    } on DioError catch (_, __) {
      log('DioError', error: _, stackTrace: __);
      return '';
    }
  }

  @override
  Future<Result<List<String>>> getContent(Chapter chapter) async {
    try {
      final url = chapter.url;

      final Response response = await _customDio.get(url, responseType: ResponseType.plain);
      final Document document = parse(response.data);

      final List<String> getContent = [];

      final novelContent = document.querySelector('.reading-content .text-left');
      if (novelContent != null) {
        for (var element in novelContent.children) {
          final text = element.text.trim();
          if (text.isNotEmpty) getContent.add(text);
        }
      }

      for (Element img in document.querySelectorAll('.reading-content img')) {
        final source = ScrapingUtil(img).getImage();
        if (source.isNotEmpty) getContent.add(source);
      }

      return Result.success(getContent);
    } on DioError catch (_, __) {
      log('DioError', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }
}
