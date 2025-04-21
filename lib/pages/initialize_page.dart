import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/wheel_item.dart';
import 'wheel_page.dart';

class InitializePage extends StatefulWidget {
  const InitializePage({Key? key}) : super(key: key);

  @override
  _InitializePageState createState() => _InitializePageState();
}

class _InitializePageState extends State<InitializePage> {
  final List<WheelItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _presetNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(); // 用于输入转盘标题
  double _currentRatio = 1.0;
  Color _currentColor = Colors.white;
  bool _showColorPicker = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultPresets(); // 加载默认预设
    _currentColor = _generateRandomColor();
  }

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  void _addNewItem() {
    String name = _nameController.text;

    if (name.isNotEmpty && _currentRatio > 0) {
      setState(() {
        _items.add(WheelItem(name: name, ratio: _currentRatio, color: _currentColor));
        _nameController.clear();
        _currentRatio = 1.0;
        _currentColor = _generateRandomColor();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的名称和比例')),
      );
    }
  }

  void _navigateToWheelPage() {
    String title = _titleController.text.isNotEmpty ? _titleController.text : '转盘抽奖';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WheelPage(items: _items, title: title),
      ),
    );
  }

  void _pickColor() {
    setState(() {
      _showColorPicker = !_showColorPicker;
    });
  }

  void _increaseRatio() {
    setState(() {
      _currentRatio += 1.0;
    });
  }

  void _decreaseRatio() {
    setState(() {
      if (_currentRatio > 0) {
        _currentRatio -= 1.0;
      }
    });
  }

  void _clearItems() {
    setState(() {
      _items.clear();
      _titleController.clear(); // 清除标题
      _presetNameController.clear(); // 清除预设名称
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('转盘数据已清空')),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // 保存预设
  Future<void> _savePresets(String presetName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> itemsJson = _items.map((item) => item.toJson()).toList();
    await prefs.setString('wheel_presets_$presetName', jsonEncode({
      'title': _titleController.text,
      'items': itemsJson,
    }));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('预设 "$presetName" 已保存')),
    );
    _presetNameController.clear(); // 保存成功后清除预设名称框
  }

  // 加载预设
  Future<void> _loadPresets(String presetName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? presetsJson = prefs.getString('wheel_presets_$presetName');
    if (presetsJson != null) {
      Map<String, dynamic> presetData = jsonDecode(presetsJson);
      List<dynamic> itemsJson = presetData['items'];
      List<WheelItem> loadedItems = itemsJson.map((itemJson) => WheelItem.fromJson(itemJson)).toList();
      setState(() {
        _items.clear();
        _items.addAll(loadedItems);
        _titleController.text = presetData['title'];
        _presetNameController.text = presetName;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('预设 "$presetName" 不存在')),
      );
    }
  }

  // 加载默认预设
  Future<void> _loadDefaultPresets() async {
    await _loadPresets('default');
  }

  // 删除预设
  Future<void> _deletePresets(String presetName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('wheel_presets_$presetName');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('预设 "$presetName" 已删除')),
    );
  }

  // 获取所有预设名称
  Future<List<String>> _getAllPresets() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> presetNames = [];
    for (String key in prefs.getKeys()) {
      if (key.startsWith('wheel_presets_')) {
        presetNames.add(key.split('wheel_presets_').last);
      }
    }
    return presetNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('初始化转盘'),
      ),
      body: SingleChildScrollView( // 添加可滚动的视图
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '转盘标题'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '子项名称'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _decreaseRatio,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 10),
                Text('权重: $_currentRatio'),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _increaseRatio,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    color: _currentColor,
                    child: Center(
                      child: Text(
                        '#${_currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                        style: TextStyle(color: _currentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.colorize),
                  onPressed: _pickColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addNewItem,
              child: const Text('添加项目'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _items.length > 1 ? _navigateToWheelPage : null,
              child: const Text('完成初始化'),
            ),
            const SizedBox(height: 20),
            // 列表显示在预设功能的上方
            if (_items.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300), // 设置最大高度
                child: ListView.builder(
                  shrinkWrap: true, // 允许子项包裹内容
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.color,
                        child: Text(
                          '${item.ratio}',
                          style: TextStyle(color: item.color.computeLuminance() < 0.5 ? Colors.white : Colors.black),
                        ),
                      ),
                      title: Text(item.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeItem(index),
                      ),
                    );
                  },
                ),
              ),
            if (_items.isNotEmpty)
              ElevatedButton(
                onPressed: _clearItems,
                child: const Text('清除转盘'),
              ),
            const SizedBox(height: 20),
            // 预设功能相关控件放在下方
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _presetNameController,
                    decoration: const InputDecoration(labelText: '预设名称'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    String presetName = _presetNameController.text;
                    if (presetName.isNotEmpty) {
                      _savePresets(presetName);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请输入预设名称')),
                      );
                    }
                  },
                  child: const Text('保存预设'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                List<String> presets = await _getAllPresets();
                if (presets.isNotEmpty) {
                  String? selectedPreset = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(0, 0, 0, 0),
                    items: presets.map((name) {
                      return PopupMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                  );
                  if (selectedPreset != null) {
                    await _loadPresets(selectedPreset);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('没有找到任何预设')),
                  );
                }
              },
              child: const Text('加载预设'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                List<String> presets = await _getAllPresets();
                if (presets.isNotEmpty) {
                  String? selectedPreset = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(0, 0, 0, 0),
                    items: presets.map((name) {
                      return PopupMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                  );
                  if (selectedPreset != null) {
                    await _deletePresets(selectedPreset);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('没有找到任何预设')),
                  );
                }
              },
              child: const Text('删除预设'),
            ),
          ],
        ),
      ),
      bottomSheet: _showColorPicker ? WillPopScope(
        onWillPop: () async {
          _pickColor(); // 关闭颜色选择器
          return false; // 阻止默认的返回行为
        },
        child: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (Color color) {
              setState(() {
                _currentColor = color;
              });
            },
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsv,
            labelTypes: const [],
          ),
        ),
      ) : null,
    );
  }
}