import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database/recetas_model.dart';

class RecetaDetalleScreen extends StatefulWidget {
  final Receta receta;

  const RecetaDetalleScreen({
    Key? key,
    required this.receta,
  }) : super(key: key);

  @override
  _RecetaDetalleScreenState createState() => _RecetaDetalleScreenState();
}

class _RecetaDetalleScreenState extends State<RecetaDetalleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _mostrarIngredientes = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.receta.imagenUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error, size: 40, color: Colors.grey[400]),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y descripción
                  Text(
                    widget.receta.titulo,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.receta.descripcion,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Información nutricional
                  _buildInfoNutricional(),
                  SizedBox(height: 24),

                  // Tabs de Ingredientes e Instrucciones
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Ingredientes'),
                      Tab(text: 'Instrucciones'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                  ),
                  SizedBox(height: 16),

                  // Contenido de los tabs
                  SizedBox(
                    height: 300, // Altura fija para el contenido de los tabs
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildIngredientes(),
                        _buildInstrucciones(),
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

  Widget _buildInfoNutricional() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Nutricional',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrienteItem('Calorías', '${widget.receta.calorias} kcal'),
              _buildNutrienteItem('Proteínas', '${widget.receta.proteinas}g'),
              _buildNutrienteItem('Carbos', '${widget.receta.carbohidratos}g'),
              _buildNutrienteItem('Grasas', '${widget.receta.grasas}g'),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoAdicional(Icons.timer, '${widget.receta.tiempoPreparacion} min'),
              _buildInfoAdicional(Icons.restaurant_menu, widget.receta.dificultad),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrienteItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAdicional(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientes() {
    return ListView.builder(
      itemCount: widget.receta.ingredientes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.receta.ingredientes[index].nombre,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstrucciones() {
    return ListView.builder(
      itemCount: widget.receta.instrucciones.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.receta.instrucciones[index],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 