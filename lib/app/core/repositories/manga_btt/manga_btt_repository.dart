part of '../book_repository.dart';

class _MangaBTTRepository extends ILoadBook {
  _MangaBTTRepository() : super(index: 1, initialIndex: 1);

  @override
  Fonte get fonte => Fonte.MANGA_BTT;

  static final _MangaBTTRepository _instance = _MangaBTTRepository();

  @override
  Future<String> getURLByTitle(String title) {
    throw UnimplementedError();
  }

  @override
  Future<Book> getBookByURL(String title) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Book>> bookInfo(Book book) async {
    try {
      final old = DateTime.now();

      // final String title = book.title;
      final String mainURL = book.url;

      final Response response = await _customDio.get(mainURL, responseType: ResponseType.plain);

      final Document document = parse(response.data);

      final List<Chapter> chapters = [];

      final ScrapingUtil scrapingUtil = ScrapingUtil.bySelector(document, selector: '#item-detail');

      if (scrapingUtil.error) return Result.failure(Exception());

      // Categorias
      final List<Tags>? tags = scrapingUtil.getInfo<List<Tags>>(
        selector: '.kind.row .tr-theloai',
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
      String? status;
      // Status
      final statusTemp = scrapingUtil.element.querySelectorAll('.status.row p')..removeWhere((element) => !element.text.contains('Ongoing'));
      if (statusTemp.length == 1) status = statusTemp.first.text.dataOrNull;

      // scrapingUtil.getInfo<String>(
      //   selector: '.status.row',
      //   stringRemove: (remove) => 'Status',
      //   endSelector: '.col-xs-10',
      // );

      // Image
      String? image = scrapingUtil.getImage(selector: 'img').dataOrNull;

      if (image?.contains('com//') ?? false) image = image?.replaceAll('com//', 'com/');

      // Sinopse
      final String sinopse = scrapingUtil.getByText(selector: '#summary');

      final id = mainURL.split('-').last;

      const chapterSubKey = 'Story/ListChapterByStoryID';
      final chapterUrlRequest = '$baseURL/$chapterSubKey';

      final Response chaptersResponse = await _customDio.post(
        chapterUrlRequest,
        responseType: ResponseType.json,
        params: {"StoryID": id},
      );

      final Document chaptersDocument = parse(chaptersResponse.data);

      final elements = chaptersDocument.querySelectorAll('.row');

      for (final element in elements) {
        final ScrapingUtil scrapingUtil = ScrapingUtil(element);
        final String url = scrapingUtil.getURL(selector: 'a');
        // final String? elementCreatedAt = scrapingUtil.createdAt();
        String name = scrapingUtil.getByText(selector: 'a');

        if ([url, name].hasEmpty) continue;

        final (chapterDescription, chapterNumber, title, chapterFix, chapterVersion) = DataParse.titleParse(name);

        final chapter = Chapter(
          id: url.urlToId,
          chapterFix: chapterFix,
          chapterVersion: chapterVersion,
          chapterNumber: chapterNumber,
          chapterDescription: chapterDescription,
          fonte: Fonte.MANGA_BTT,
          // createdAt: elementCreatedAt,
          url: url,
          chapterName: title,
        );

        if (!chapters.contains(chapter)) chapters.add(chapter);
      }

      final newBook = book.copyWith(
        originalImage: book.originalImage.isEmpty ? image : null,
        mediumImage: image,
        status: status,
        tags: tags,
        sinopse: DataParse.sinopseParse(sinopse),
        chapters: chapters.reversed.toList(),
      );

      log('${DateTime.now().difference(old)}');

      return Result.success(newBook);
    } on DioError catch (_, __) {
      log('Algo ruím aconteceu', error: _, stackTrace: __);
      return Result.failure(_);
    } on Exception catch (_, __) {
      log('Algo ruím aconteceu', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    try {
      final now = DateTime.now();
      // print(_customDio.interceptors);
      if (isSuccess && _hasMore) index++;
      // final subKey = 'page/$index/?s&post_type=wp-manga&m_orderby=${_type.order}';
      final subKey = 'find-story?status=-1&sort=0&page=$index';
      // final subKey = 'manga/page/${index ?? this.index}/?m_orderby=${type.order}';
      final String mainURL = '$baseURL/$subKey';
      final Response response = await _customDio.get(mainURL, responseType: ResponseType.plain);
      final Document document = parse(response.data);

      final elements = document.querySelectorAll('body .item');

      for (final element in elements) {
        String? lastChapter;
        final ScrapingUtil scrapingUtil = ScrapingUtil(element);
        final String url = scrapingUtil.getURL(selector: 'h3 a');
        final String title = scrapingUtil.getByText(selector: 'h3 a');
        final String? chapter = scrapingUtil.getByText(selector: '.chapter.clearfix a').dataOrNull;

        if ((chapter?.contains('.') ?? false) && chapter != null) {
          final (_, chapterNumber, _, _, _) = DataParse.titleParse(chapter);
          lastChapter = 'Capítulo $chapterNumber';
        } else if (chapter != null) {
          lastChapter = 'Capítulo ${double.tryParse(chapter.replaceAll(RegExp(r'[^0-9]'), ''))}';
        }

        String originalImage = scrapingUtil.getImage(selector: 'img');

        if (originalImage.contains('com//')) originalImage = originalImage.replaceAll('com//', 'com/');

        if ([url, title].hasEmpty) continue;

        final Book book = Book(
          id: url.urlToId,
          fonte: Fonte.MANGA_BTT,
          url: url,
          lastChapter: lastChapter,
          originalImage: originalImage,
          title: title,
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
  Future<Result<List<String>>> getContent(Chapter chapter) async {
    try {
      final url = chapter.url;

      final Response response = await _customDio.get(url, responseType: ResponseType.plain);
      final Document document = parse(response.data);

      final List<String> getContent = [];

      final novelContent = document.querySelector('.reading .text-left');
      if (novelContent != null) {
        for (final element in novelContent.children) {
          final text = element.text.trim();
          if (text.isNotEmpty) getContent.add(text);
        }
      }

      for (Element img in document.querySelectorAll('.reading img')) {
        final source = ScrapingUtil(img).getImage();
        if (source.isNotEmpty) getContent.add(source);
      }

      return Result.success(getContent);
    } on DioError catch (_, __) {
      log('Error', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }
}
