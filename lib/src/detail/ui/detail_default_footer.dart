import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/detail_page_screen.dart';

class DetailDefaultFooter<T> extends StatelessWidget {
  final List<T> items;
  final T currentItem;
  final PageController pageController;

  int get totalPage => items.length;
  int get currentPageIndex => items.indexOf(currentItem);

  const DetailDefaultFooter({
    super.key,
    required this.pageController,
    required this.items,
    required this.currentItem,
  });

  // int get totalPage => widget.items.length;
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
                  if (totalPage > 1) _buildPreviousButton(),
                  _buildPageIndex(),
                  if (totalPage > 1) _buildNextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndex() {
    if (currentPageIndex == -1) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Text(
            "${currentPageIndex + 1}/$totalPage",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastPage = currentPageIndex >= totalPage - 1;
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed:
            isLastPage
                ? null
                : () {
                  pageController.nextPage(
                    duration: kNextPageDuration,
                    curve: Curves.decelerate,
                  );
                },
        icon: Icon(Icons.arrow_forward_rounded),
      ),
    );
  }

  Widget _buildPreviousButton() {
    final isFirstPage = currentPageIndex <= 0;

    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed:
            isFirstPage
                ? null
                : () {
                  pageController.previousPage(
                    duration: kNextPageDuration,
                    curve: Curves.decelerate,
                  );
                },
        icon: Icon(Icons.arrow_back_rounded),
      ),
    );
  }
}
