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
    required thi