import 'package:flutter/material.dart';

/// FloatingActionButton expansível com menu de opções.
/// 
/// Exibe um FAB principal que, ao ser tocado, expande um menu
/// com múltiplas opções em overlay sobre a tela.
/// 
/// Inclui animações de rotação e escala para melhor UX.
class ExpandableFabMenu extends StatefulWidget {
  /// Itens do menu a serem exibidos
  final List<ExpandableFabMenuItem> items;
  
  /// Ícone do FAB principal (padrão: add)
  final Widget? icon;
  
  /// Ícone quando o menu está aberto (padrão: close implícito via rotação)
  final Widget? activeIcon;
  
  /// Cor de fundo do FAB
  final Color? backgroundColor;
  
  /// Cor do ícone do FAB
  final Color? foregroundColor;

  /// Cria um FAB menu expansível
  /// 
  /// [items] - Lista de itens a exibir no menu
  /// [icon] - Ícone opcional personalizado
  /// [activeIcon] - Ícone opcional para estado ativo
  /// [backgroundColor] - Cor de fundo opcional
  /// [foregroundColor] - Cor do ícone opcional
  const ExpandableFabMenu({
    Key? key,
    required this.items,
    this.icon,
    this.activeIcon,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<ExpandableFabMenu> createState() => _ExpandableFabMenuState();
}

class _ExpandableFabMenuState extends State<ExpandableFabMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.375, // 135 graus (transforma + em x)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _controller.reverse().then((_) {
        _removeOverlay();
      });
    } else {
      _insertOverlay();
      _controller.forward();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _insertOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Fundo escuro (Backdrop)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black54),
              ),
            ),
            // Itens do menu posicionados
            Positioned(
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.topRight,
                followerAnchor: Alignment.bottomRight,
                offset: const Offset(0, -16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: _buildExpandedItems(),
                ),
              ),
            ),
            // FAB principal no overlay
            Positioned(
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.topLeft,
                followerAnchor: Alignment.topLeft,
                child: FloatingActionButton(
                  onPressed: _toggleMenu,
                  backgroundColor:
                      widget.backgroundColor ??
                      Theme.of(context).colorScheme.secondary,
                  foregroundColor:
                      widget.foregroundColor ??
                      Theme.of(context).colorScheme.onSecondary,
                  elevation: 6,
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child: widget.icon ?? const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildExpandedItems() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < widget.items.length; i++)
          _buildItem(widget.items[i], i),
      ],
    );
  }

  Widget _buildItem(ExpandableFabMenuItem item, int index) {
    return ScaleTransition(
      scale: _expandAnimation,
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 8.0,
          right: 4.0,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _toggleMenu();
              item.onPressed();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color:
                          item.iconColor ??
                          Theme.of(context).colorScheme.primary,
                      size: 25,
                    ),
                    child: item.icon,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FloatingActionButton(
        backgroundColor: _isOpen
            ? Colors.transparent
            : (widget.backgroundColor ??
                  Theme.of(context).colorScheme.secondary),
        foregroundColor: _isOpen
            ? Colors.transparent
            : (widget.foregroundColor ??
                  Theme.of(context).colorScheme.onSecondary),
        elevation: _isOpen ? 0 : 6,
        onPressed: _toggleMenu,
        child: _isOpen
            ? null
            : RotationTransition(
                turns: _rotateAnimation,
                child: widget.icon ?? const Icon(Icons.add),
              ),
      ),
    );
  }
}

/// Item do menu expansível.
class ExpandableFabMenuItem {
  /// Label/texto do item
  final String label;
  
  /// Ícone do item
  final Widget icon;
  
  /// Ação ao tocar no item
  final VoidCallback onPressed;
  
  /// Cor de fundo opcional
  final Color? color;
  
  /// Cor do ícone opcional
  final Color? iconColor;

  /// Cria um item do menu
  /// 
  /// [label] - Texto do item
  /// [icon] - Ícone widget
  /// [onPressed] - Callback de ação
  /// [color] - Cor de fundo opcional
  /// [iconColor] - Cor do ícone opcional
  ExpandableFabMenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.iconColor,
  });
}
