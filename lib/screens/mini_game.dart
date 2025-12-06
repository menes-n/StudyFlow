import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Yılan Oyunu (basic snake)
// - Swipe ile yön kontrolü
// - Elma yedikçe uzar
// - Kenarlara veya kendine çarptığında oyun biter

enum _Dir { up, down, left, right }

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  static const int rows = 18;
  static const int cols = 14;
  static const Duration tickDuration = Duration(milliseconds: 350);

  Timer? _timer;
  final Random _rand = Random();

  // Snake represented as list of cells (row, col). head = first element.
  List<Point<int>> _snake = [];
  Point<int> _apple = const Point(0, 0);
  _Dir _dir = _Dir.right;
  bool _running = false;
  bool _gameOver = false;
  int _score = 0;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _highScore = prefs.getInt('mini_high_score') ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _saveScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mini_last_score', _score);
      final existing = prefs.getInt('mini_high_score') ?? 0;
      if (_score > existing) {
        await prefs.setInt('mini_high_score', _score);
        setState(() {
          _highScore = _score;
        });
      }
    } catch (_) {}
  }

  void _resetGame() {
    _timer?.cancel();
    _snake = [Point(rows ~/ 2, cols ~/ 2), Point(rows ~/ 2, cols ~/ 2 - 1)];
    _dir = _Dir.right;
    _placeApple();
    _running = false;
    _gameOver = false;
    _score = 0;
    setState(() {});
  }

  void _startGame() {
    if (_running) return;
    // If the previous game ended, reset the board first so the snake
    // doesn't remain in a collided position and immediately end again.
    if (_gameOver) {
      _resetGame();
    }
    _running = true;
    _gameOver = false;
    _timer = Timer.periodic(tickDuration, (_) => _tick());
    setState(() {});
  }

  void _placeApple() {
    while (true) {
      final r = _rand.nextInt(rows);
      final c = _rand.nextInt(cols);
      final p = Point(r, c);
      if (!_snake.contains(p)) {
        _apple = p;
        break;
      }
    }
  }

  void _tick() {
    if (!_running) return;

    final head = _snake.first;
    Point<int> newHead;
    switch (_dir) {
      case _Dir.up:
        newHead = Point(head.x - 1, head.y);
        break;
      case _Dir.down:
        newHead = Point(head.x + 1, head.y);
        break;
      case _Dir.left:
        newHead = Point(head.x, head.y - 1);
        break;
      case _Dir.right:
        newHead = Point(head.x, head.y + 1);
        break;
    }

    // Check collisions with walls
    if (newHead.x < 0 ||
        newHead.x >= rows ||
        newHead.y < 0 ||
        newHead.y >= cols) {
      _endGame();
      return;
    }

    // Check self collision
    if (_snake.contains(newHead)) {
      _endGame();
      return;
    }

    // Move
    setState(() {
      _snake.insert(0, newHead);
      if (newHead == _apple) {
        _score += 1;
        _placeApple();
        // don't remove tail (grow)
      } else {
        _snake.removeLast();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    _running = false;
    _gameOver = true;
    // Save scores when game ends
    _saveScores();
    setState(() {});
  }

  void _changeDir(_Dir d) {
    // Prevent reversing directly
    if ((_dir == _Dir.left && d == _Dir.right) ||
        (_dir == _Dir.right && d == _Dir.left) ||
        (_dir == _Dir.up && d == _Dir.down) ||
        (_dir == _Dir.down && d == _Dir.up)) {
      return;
    }
    setState(() => _dir = d);
  }

  void _onVerticalDrag(DragUpdateDetails details) {
    final dy = details.primaryDelta ?? 0;
    if (dy < -6) _changeDir(_Dir.up);
    if (dy > 6) _changeDir(_Dir.down);
  }

  void _onHorizontalDrag(DragUpdateDetails details) {
    final dx = details.primaryDelta ?? 0;
    if (dx < -6) _changeDir(_Dir.left);
    if (dx > 6) _changeDir(_Dir.right);
  }

  @override
  void dispose() {
    try {
      _timer?.cancel();
    } catch (_) {}
    super.dispose();
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(child: Icon(icon, color: Colors.white, size: 28)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yılan Oyunu')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skor: $_score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'En Yüksek: $_highScore',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  _gameOver ? 'Oyun Bitti' : (_running ? 'Oynanıyor' : 'Hazır'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: _onVerticalDrag,
                onHorizontalDragUpdate: _onHorizontalDrag,
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardW = constraints.maxWidth;
                        final boardH = constraints.maxHeight;
                        final cellW = boardW / cols;
                        final cellH = boardH / rows;
                        const cellMargin = 2.0;

                        // Build background grid cells (light) - optional
                        List<Widget> stackChildren = [];

                        // Optional subtle grid background (not each cell widget heavy)
                        // Draw snake segments and apple as positioned widgets

                        // Apple (discrete position)
                        stackChildren.add(
                          Positioned(
                            left: _apple.y * cellW + cellMargin,
                            top: _apple.x * cellH + cellMargin,
                            width: cellW - cellMargin * 2,
                            height: cellH - cellMargin * 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        // Snake segments (head first)
                        for (int i = 0; i < _snake.length; i++) {
                          final seg = _snake[i];
                          final isHead = i == 0;
                          stackChildren.add(
                            Positioned(
                              left: seg.y * cellW + cellMargin,
                              top: seg.x * cellH + cellMargin,
                              width: cellW - cellMargin * 2,
                              height: cellH - cellMargin * 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isHead
                                      ? Colors.green[800]
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // Optionally draw faint grid lines using positioned containers
                        // We'll add lightweight cell borders to hint grid
                        for (int r = 0; r < rows; r++) {
                          for (int c = 0; c < cols; c++) {
                            stackChildren.add(
                              Positioned(
                                left: c * cellW,
                                top: r * cellH,
                                width: cellW,
                                height: cellH,
                                child: Container(
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(3),
                                    // subtle border
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.02),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        return Stack(children: stackChildren);
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _running ? null : _startGame,
                    onLongPress: null,
                    child: Text(
                      _running
                          ? 'Oyun Sürüyor'
                          : (_gameOver ? 'Tekrar Oyna' : 'Başlat'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _resetGame,
                  child: const Text('Sıfırla'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Eşit aralıklı 3x3 ızgara içinde yön tuşları
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                  children: [
                    const SizedBox.shrink(),
                    Tooltip(
                      message: 'Yukarı',
                      child: _controlButton(
                        Icons.keyboard_arrow_up,
                        () => _changeDir(_Dir.up),
                      ),
                    ),
                    const SizedBox.shrink(),

                    Tooltip(
                      message: 'Sol',
                      child: _controlButton(
                        Icons.keyboard_arrow_left,
                        () => _changeDir(_Dir.left),
                      ),
                    ),
                    const SizedBox.shrink(),
                    Tooltip(
                      message: 'Sağ',
                      child: _controlButton(
                        Icons.keyboard_arrow_right,
                        () => _changeDir(_Dir.right),
                      ),
                    ),

                    const SizedBox.shrink(),
                    Tooltip(
                      message: 'Aşağı',
                      child: _controlButton(
                        Icons.keyboard_arrow_down,
                        () => _changeDir(_Dir.down),
                      ),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
