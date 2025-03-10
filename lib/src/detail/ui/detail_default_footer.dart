import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/detail_page_screen.dart';

class DetailDefaultFooter<T> extends StatefulWidget {
  final int totalPage;
  final PageController pageController;

  const DetailDefaultFooter({
    super.key,
    required this.totalPage,
    required this.pageController,
  });

  @override
  State<DetailDefaultFooter<T>> createState() => _DetailDefaultFooterState<T>();
}

class _DetailDefaultFooterState<T> extends State<DetailDefaultFooter<T>> {
  int _currentPage = 0;
  int get currentPage => this._currentPage;

  set currentPage(int value) {
    if (this._currentPage != value) {
      this._currentPage = value;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    widget.pageController.addListener(_onPageChanged);
    _currentPage = widget.pageController.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          children: [
            Divider(thickness: 1, color: Colors.black12, height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.totalPage > 1) _buildPreviousButton(),
                  _buildPageIndex(),
                  if (widget.totalPage > 1) _buildNextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndex() {
    if (currentPage == -1) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Text(
            "${currentPage + 1}/${widget.totalPage}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastPage = currentPage >= widget.totalPage - 1;
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed:
            isLastPage
                ? null
                : () {
                  widget.pageController.nextPage(
                    duration: kNextPageDuration,
                    curve: Curves.decelerate,
                  );
                },
        icon: Icon(Icons.arrow_forward_rounded),
      ),
    );
  }

  Widget _buildPreviousButton() {
    final isFirstPage = currentPage <= 0;

    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed:
            isFirstPage
                ? null
                : () {
                  widget.pageController.previousPage(
                    duration: kNextPageDuration,
                    curve: Curves.decelerate,
                  );
                },
        icon: Icon(Icons.arrow_back_rounded),
      ),
    );
  }

  void _onPageChanged() {
    final page = widget.pageController.page;
    if (page == null) return;

    currentPage = page.round();
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    super.dispose();
  }
}
