import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// A widget that displays tenant logos with automatic URL resolution
/// Handles both direct URLs and file names that need to be resolved via the download API
class TenantLogo extends StatefulWidget {
  final String? logoUrl; // Logo file name from tenant data
  final String tenantId; // Tenant ID for URL resolution
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final String fallbackUrl;
  final Widget? placeholder;
  final Widget? errorWidget;

  const TenantLogo({
    super.key,
    required this.logoUrl,
    required this.tenantId,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.fallbackUrl = 'https://via.placeholder.com/80x80',
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<TenantLogo> createState() => _TenantLogoState();
}

class _TenantLogoState extends State<TenantLogo> {
  String? _resolvedUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _resolveLogoUrl();
  }

  @override
  void didUpdateWidget(TenantLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-resolve if the logo file name or tenant ID changed
    if (oldWidget.logoUrl != widget.logoUrl || oldWidget.tenantId != widget.tenantId) {
      _resolveLogoUrl();
    }
  }

  Future<void> _resolveLogoUrl() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      smPrint('Resolving tenant logo for tenant: ${widget.tenantId}');

      // Use the tenant logo resolver with fallback
      // final resolvedUrl = await ImageUrlResolver.resolveTenantLogoWithFallback(
      //   logoFileName: widget.logoFileName,
      //   tenantId: widget.tenantId,
      //   fallbackUrl: widget.fallbackUrl,
      // );

      if (mounted) {
        setState(() {
          _resolvedUrl = widget.logoUrl;
          _isLoading = false;
          _hasError = false; // Never set error since we always have fallback
        });
      }
      
    } catch (e) {
      smPrint('Error resolving tenant logo: $e');
      if (mounted) {
        setState(() {
          _resolvedUrl = widget.fallbackUrl;
          _isLoading = false;
          _hasError = false; // Use fallback instead of error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: DesignSystem.internetImage(
        imageUrl: _resolvedUrl ?? widget.fallbackUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: widget.borderRadius),
      child: Center(
        child: SizedBox(
          width: (widget.width ?? 80) * 0.25,
          height: (widget.height ?? 80) * 0.25,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: widget.borderRadius),
      child: Center(
        child: Icon(Icons.business, color: Colors.grey[400], size: (widget.width ?? 80) * 0.3),
      ),
    );
  }
}

/// Convenient static methods for common tenant logo use cases
class TenantLogoHelper {
  TenantLogoHelper._();

  /// Create a standard tenant logo widget with common settings
  static Widget standard({
    required String? logoFileName,
    required String tenantId,
    double size = 80,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return TenantLogo(
      logoUrl: logoFileName,
      tenantId: tenantId,
      width: size.rSp,
      height: size.rSp,
      fit: fit,
      borderRadius: borderRadius,
    );
  }

  /// Create a small tenant logo widget (24x24)
  static Widget small({required String? logoFileName, required String tenantId, BoxFit fit = BoxFit.cover}) {
    return TenantLogo(logoUrl: logoFileName, tenantId: tenantId, width: 24.rSp, height: 24.rSp, fit: fit);
  }

  /// Create a medium tenant logo widget (48x48)
  static Widget medium({required String? logoFileName, required String tenantId, BoxFit fit = BoxFit.cover}) {
    return TenantLogo(logoUrl: logoFileName, tenantId: tenantId, width: 48.rSp, height: 48.rSp, fit: fit);
  }

  /// Create a large tenant logo widget (120x120)
  static Widget large({required String? logoFileName, required String tenantId, BoxFit fit = BoxFit.cover}) {
    return TenantLogo(logoUrl: logoFileName, tenantId: tenantId, width: 120.rSp, height: 120.rSp, fit: fit);
  }
}
