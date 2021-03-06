import 'package:flutter/material.dart';

import 'InheritedSearchWidget.dart';
import 'SearchBar.dart';
import 'SearchBarAttrs.dart';
import 'SearchBarButton.dart';

class SearchBarBuilder extends StatelessWidget {
  SearchBarBuilder(SearchBarState state)
      : _widget = state.widget,
        _attrs = state.widget.attrs,
        _state = state;

  final SearchBar _widget;

  final SearchBarAttrs _attrs;

  final SearchBarState _state;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _state.onWillPop,
      child: _buildSearchBarWidget(),
    );
  }

  Widget _buildSearchBarWidget() {
    final appBar = _buildAppBar();
    if (_widget.loader != null) {
      return _wrapWithLoader(appBar);
    } else {
      return appBar;
    }
  }

  Widget _wrapWithLoader(Widget appBar) {
    return Stack(
      children: [
        Positioned(
          top: _searchBarTotalHeight,
          height: _loaderHeight,
          left: 0.0,
          right: 0.0,
          child: _buildLoaderWidget(),
        ),
        Positioned(
          top: 0.0,
          height: _searchBarTotalHeight,
          left: 0.0,
          right: 0.0,
          child: appBar,
        ),
      ],
    );
  }

  Widget _buildLoaderWidget() {
    return InheritedSearchQuery(
      query: _state.loaderQuery,
      child: _widget.loader,
    );
  }

  Widget _buildAppBar() {
    if (isInDefaultState) {
      return _buildDefaultBar();
    } else if (isInMergedState) {
      return _buildMergedBar();
    } else {
      return _buildSearchBar();
    }
  }

  bool get isInDefaultState => _widget.iconified && !_state.expanded;

  bool get isInMergedState => !_widget.iconified && !_state.activated;

  Widget _buildDefaultBar() {
    return AppBar(
      title: _widget.defaultAppBar.title,
      actions: _defaultActionsOrEmpty()..insert(0, _buildSearchAction()),
    );
  }

  List<Widget> _defaultActionsOrEmpty() => _widget.defaultAppBar.actions ?? [];

  Widget _buildSearchAction() {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: _state.onSearchAction,
    );
  }

  Widget _buildMergedBar() {
    return _buildBaseBar(
      content: [
        _widget.defaultAppBar.leading,
        _buildSearchStackContainer(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return _buildBaseBar(
      content: [
        _buildCancelSearchButton(),
        _buildSearchStackContainer(),
      ],
    );
  }

  Widget _buildBaseBar({List<Widget> content}) {
    return Container(
      color: _attrs.searchBarColor,
      child: Material(
        borderRadius: BorderRadius.zero,
        elevation: _attrs.searchBarElevation,
        child: Container(
          height: _searchBarTotalHeight,
          color: _attrs.searchBarColor,
          child: Container(
            margin: _attrs.searchBarTopMargin,
            child: Padding(
              padding: _attrs.searchBarPadding,
              child: Row(children: content),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSearchButton() {
    return SearchBarButton(
      icon: Icons.arrow_back,
      color: _attrs.primaryColor,
      onPressed: _state.onCancelSearch,
    );
  }

  Widget _buildSearchStackContainer() {
    return Expanded(
      child: Container(
        height: _attrs.searchTextFieldHeight,
        margin:
            EdgeInsets.symmetric(horizontal: _attrs.searchBoxHorizontalMargin),
        decoration: _buildSearchTextBoxDecoration(),
        child: _buildSearchStack(),
      ),
    );
  }

  Widget _buildSearchStack() {
    return Stack(
      children: [
        _buildSearchTextField(),
        _buildHighlightButton(),
        _state.focused ? _buildClearButton() : null,
      ].where((it) => it != null).toList(),
    );
  }

  Widget _buildSearchTextField() {
    return Positioned.fill(
      child: Center(
        child: TextField(
          style: TextStyle(
            color: _attrs.primaryColor,
            fontSize: _attrs.fontSize,
          ),
          autofocus: _widget.autofocus,
          focusNode: _state.searchFocusNode,
          controller: _state.queryInputController,
          onChanged: _state.onTextChange,
          onSubmitted: _state.onTextSubmit,
          decoration: _buildSearchTextFieldDecoration(),
        ),
      ),
    );
  }

  BoxDecoration _buildSearchTextBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: _attrs.textBoxOutlineColor,
        width: _attrs.textBoxOutlineWidth,
      ),
      borderRadius: BorderRadius.all(Radius.circular(_attrs.textBoxOutlineRadius)),
      color: _attrs.textBoxBackgroundColor,
    );
  }

  InputDecoration _buildSearchTextFieldDecoration() {
    return InputDecoration(
      contentPadding: _attrs.searchTextFieldPadding,
      border: InputBorder.none,
      hintText: _widget.searchHint,
      hintStyle: TextStyle(
          color: !_state.focused ? _attrs.secondaryColor : _attrs.disabledTextColor),
    );
  }

  Widget _buildHighlightButton() {
    return Positioned(
      left: 0.0,
      top: 0.0,
      bottom: 0.0,
      child: Container(
        margin: _attrs.highlightButtonMargin,
        child: SearchBarButton(
          icon: Icons.search,
          color: _state.queryNotEmpty || !_state.focused
              ? _attrs.primaryColor
              : _attrs.secondaryColor,
          onPressed: _state.onPrefixSearchTap,
          padding: EdgeInsets.all(4.0),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Positioned(
      right: 0.0,
      top: 0.0,
      bottom: 0.0,
      child: Container(
        margin: _attrs.clearButtonMargin,
        child: SearchBarButton(
          icon: Icons.clear,
          color: _state.queryNotEmpty
              ? _attrs.primaryColor
              : _attrs.secondaryColor,
          onPressed: _state.onClearQuery,
          padding: EdgeInsets.all(4.0),
        ),
      ),
    );
  }

  double get _searchBarTotalHeight =>
      _attrs.searchBarSize.height + _attrs.statusBarHeight;

  double get _loaderHeight =>
      _widget.preferredSize.height - _searchBarTotalHeight;
}
