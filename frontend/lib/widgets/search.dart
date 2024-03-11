import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({super.key, required this.searchCallback, this.addCallback});
  final Function(String value) searchCallback;
  final Function()? addCallback;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      automaticallyImplyLeading: false,
      title: Container(
        width: double.infinity,
        height: 40,
        color: Theme.of(context).secondaryHeaderColor,
        child: Center(
          child: TextField(
            onChanged: (value) => searchCallback(value),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(5),
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: addCallback != null ? IconButton(
                icon: const Icon(Icons.add),
                onPressed: addCallback as void Function(),
              ) : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
