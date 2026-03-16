import 'package:flutter/material.dart';

/// Widget de paginación equivalente al Pagination.jsx de la web.
/// Recibe [currentPage], [totalPages] y [onPageChange] desde el backend.
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChange;
  final int? totalItems;
  final int? itemsPerPage;
  final bool showInfo;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    this.totalItems,
    this.itemsPerPage,
    this.showInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          if (showInfo && totalItems != null && itemsPerPage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Mostrando ${_getStartItem()} - ${_getEndItem()} de $totalItems elementos',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón anterior
              IconButton(
                onPressed: currentPage > 1
                    ? () => onPageChange(currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Página anterior',
              ),

              // Números de página
              ..._buildPageNumbers(),

              // Botón siguiente
              IconButton(
                onPressed: currentPage < totalPages
                    ? () => onPageChange(currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Página siguiente',
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getStartItem() {
    if (itemsPerPage == null) return 1;
    return ((currentPage - 1) * itemsPerPage!) + 1;
  }

  int _getEndItem() {
    if (itemsPerPage == null || totalItems == null) return totalItems ?? 0;
    final endItem = currentPage * itemsPerPage!;
    return endItem > totalItems! ? totalItems! : endItem;
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    // Lógica para mostrar páginas (similar al componente web)
    int startPage = 1;
    int endPage = totalPages;

    // Si hay muchas páginas, mostrar solo algunas alrededor de la actual
    if (totalPages > 7) {
      if (currentPage <= 4) {
        endPage = 7;
      } else if (currentPage >= totalPages - 3) {
        startPage = totalPages - 6;
      } else {
        startPage = currentPage - 3;
        endPage = currentPage + 3;
      }
    }

    // Agregar primera página y puntos suspensivos si es necesario
    if (startPage > 1) {
      pages.add(_buildPageButton(1));
      if (startPage > 2) {
        pages.add(_buildEllipsis());
      }
    }

    // Agregar páginas del rango
    for (int i = startPage; i <= endPage; i++) {
      pages.add(_buildPageButton(i));
    }

    // Agregar puntos suspensivos y última página si es necesario
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.add(_buildEllipsis());
      }
      pages.add(_buildPageButton(totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int page) {
    final isCurrentPage = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isCurrentPage ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onPageChange(page),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              page.toString(),
              style: TextStyle(
                color: isCurrentPage ? Colors.white : null,
                fontWeight: isCurrentPage ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('...'),
    );
  }
}
