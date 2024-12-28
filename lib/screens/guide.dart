import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hướng dẫn chơi'),
        backgroundColor: Colors.blue[400],
      ),
      backgroundColor: Colors.blue[300], // Đặt màu nền xanh dương
      body: Column(
        children: [
          // Sử dụng Expanded để đảm bảo nội dung không bị tràn
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Phần "Cách chơi cơ bản"
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Cách chơi cơ bản',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Tốt: Di chuyển về phía trước, chỉ tấn công theo đường chéo.\n'
                              '• Mã: Di chuyển theo hình chữ "L".\n'
                              '• Tượng: Di chuyển trên đường chéo không giới hạn.\n'
                              '• Hậu: Di chuyển trên cả hàng ngang, dọc và chéo.\n'
                              '• Vua: Di chuyển một ô theo mọi hướng.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '2. Ảnh hưởng của thời tiết',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Phần "Ảnh hưởng thời tiết"
                  DefaultTabController(
                    length: 7, // Số lượng tab
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelPadding: EdgeInsets.zero,
                          tabs: [
                            _tabItem('Nắng', Colors.orange[100]!),
                            _tabItem('Mưa', Colors.blue[100]!),
                            _tabItem('Sương mù', Colors.grey[300]!),
                            _tabItem('Tuyết', Colors.white),
                            _tabItem('Gió', Colors.grey[200]!),
                            _tabItem('Bão', Colors.grey[400]!),
                            _tabItem('Rừng', Colors.green[300]!),
                            SizedBox(width: 50),
                          ],
                        ),
                        SizedBox(
                          height: 400, // Đặt chiều cao cố định cho TabBarView
                          child: TabBarView(
                            children: [
                              _weatherEffect(
                                'Nắng (Sunny)',
                                '• Trong ánh nắng chói chang, các quân cờ có thể di chuyển một cách tự do mà không bị trở ngại. Mọi nước đi diễn ra bình thường, cho phép chiến thuật tối ưu.',
                                'assets/animations/sunny.json',
                              ),
                              _weatherEffect(
                                'Mưa (Rainy)',
                                '• Dưới cơn mưa nhẹ, quân tốt có thêm khả năng di chuyển thêm 1 ô chéo, tạo cơ hội tấn công bất ngờ. Tuy nhiên, hậu bị hạn chế chỉ di chuyển tối đa 2 ô do thời tiết ẩm ướt làm chậm bước tiến.',
                                'assets/animations/rainy.json',
                              ),
                              _weatherEffect(
                                'Sương mù (Foggy)',
                                '• Trong sương mù dày đặc, quân tốt chỉ có thể di chuyển 1 ô, trong khi vua không thể hành động. Tất cả quân cờ khác cũng bị giới hạn, khiến việc dự đoán nước đi trở nên khó khăn.',
                                'assets/animations/foggy.json',
                              ),
                              _weatherEffect(
                                'Tuyết (Snowy)',
                                '• Trên nền tuyết trắng, các quân tượng bị hạn chế chỉ di chuyển tối đa 1 ô, trong khi hậu vẫn có thể di chuyển tối đa 2 ô. Các quân cờ khác di chuyển chậm lại do lớp tuyết dày.',
                                'assets/animations/snowy.json',
                              ),
                              _weatherEffect(
                                'Gió (Windy)',
                                '• Gió mạnh giúp mã có khả năng nhảy thêm 2 ô, tận dụng sức gió để thực hiện những nước đi táo bạo. Vua cũng có thể di chuyển 2 ô, nhưng các quân cờ khác vẫn di chuyển bình thường.',
                                'assets/animations/windy.json',
                              ),
                              _weatherEffect(
                                'Bão (Stormy)',
                                '• Trong cơn bão dữ dội, mã không thể di chuyển do gió mạnh và bão tố. Vua chỉ có thể di chuyển 1 ô, trong khi các quân cờ khác bị giảm khả năng di chuyển, tạo ra một không khí căng thẳng.',
                                'assets/animations/stormy.json',
                              ),
                              _weatherEffect(
                                'Rừng (Forest)',
                                '• Trong rừng rậm, quân tốt chỉ có thể di chuyển 1 ô, và vua cũng bị giới hạn bởi cây cối. Tượng và hậu chỉ di chuyển tối đa 2 ô, các quân khác bị chậm lại do địa hình khó khăn.',
                                'assets/animations/forest.json',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String text, Color color) {
    return Container(
      width: 100, // Đặt chiều rộng cố định cho tất cả các tab
      color: color,
      child: Tab(
        child: Center( // Căn giữa nội dung trong tab
          child: Text(
            text,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _weatherEffect(String title, String effects, String animationPath) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Thêm cuộn trong mỗi TabBarView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Center( // Căn giữa animation
              child: Lottie.asset(
                animationPath,
                width: 200, // Tăng kích thước animation
                height: 200,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              effects,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}