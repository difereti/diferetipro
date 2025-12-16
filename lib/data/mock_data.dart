import '../models/data_models.dart';

class MockData {
  static final User currentUser = User(
    id: 'u1',
    role: UserRole.client,
    name: 'Juan Perez (DJ JP)',
    email: 'juan@example.com',
    phoneNumber: '3001234567',
    idType: 'CC',
    idNumber: '1144002233',
    djAlias: 'DJ JP',
    totalRepairs: 3,
  );

  static final List<Item> rentalItems = [
    Item(
      id: 'r1',
      name: 'RCF Evox 12',
      category: 'Sound',
      stock: 1,
      cost: 5000000,
      salePrice: 350000, // Rental price per day/event
      images: ['https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?auto=format&fit=crop&q=80&w=800'],
      isRental: true,
    ),
    Item(
      id: 'r2',
      name: 'Turbosound IX15',
      category: 'Sound',
      stock: 2,
      cost: 2000000,
      salePrice: 150000,
      images: ['https://images.unsplash.com/photo-1595206133361-b1633519129e?auto=format&fit=crop&q=80&w=800'],
      isRental: true,
    ),
    Item(
      id: 'r3',
      name: 'XDJ-RX3',
      category: 'DJ Gear',
      stock: 1,
      cost: 9000000,
      salePrice: 400000,
      images: ['https://images.unsplash.com/photo-1571173676743-34e45d45eb7c?auto=format&fit=crop&q=80&w=800'],
      isRental: true,
    ),
    Item(
      id: 'r4',
      name: 'Mesa DJ Portátil',
      category: 'Furniture',
      stock: 3,
      cost: 500000,
      salePrice: 50000,
      images: ['https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&q=80&w=800'],
      isRental: true,
    ),
  ];

  static final List<Item> shopItems = [
    Item(
      id: 's1',
      name: 'Cable XLR 5m',
      category: 'Cables',
      stock: 50,
      cost: 15000,
      salePrice: 35000,
      images: ['https://images.unsplash.com/photo-1621259074063-239618a8d16d?auto=format&fit=crop&q=80&w=800'],
    ),
    Item(
      id: 's2',
      name: 'Audífonos Pioneer HDJ-X5',
      category: 'Headphones',
      stock: 10,
      cost: 300000,
      salePrice: 450000,
      images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=800'],
    ),
    Item(
      id: 's3',
      name: 'Estuche Rígido para Controlador',
      category: 'Cases',
      stock: 5,
      cost: 150000,
      salePrice: 280000,
      images: ['https://images.unsplash.com/photo-1528697669527-dc53229b485d?auto=format&fit=crop&q=80&w=800'],
    ),
  ];

  static final List<Equipment> myEquipment = [
    Equipment(
      id: 'A1023',
      brand: 'Pioneer',
      model: 'CDJ-2000NXS2',
      registrationDate: DateTime.now().subtract(const Duration(days: 365)),
      ownerId: 'u1',
      thumbnail: 'https://images.unsplash.com/photo-1598653222000-6b7b7a552625?auto=format&fit=crop&q=80&w=800',
      details: 'Reproductor en buen estado general.',
      repairHistoryIds: ['MANTYREP001'],
      status: EquipmentStatus.available,
    ),
    Equipment(
      id: 'A1024',
      brand: 'Allen & Heath',
      model: 'Xone:96',
      registrationDate: DateTime.now().subtract(const Duration(days: 180)),
      ownerId: 'u1',
      thumbnail: 'https://images.unsplash.com/photo-1594434533760-02e0f3faaa68?auto=format&fit=crop&q=80&w=800',
      details: 'Mixer con leve ruido en canal 2.',
      repairHistoryIds: ['MANTYREP002'],
      status: EquipmentStatus.repair,
    ),
  ];

  static final List<Repair> repairs = [
    Repair(
      id: 'MANTYREP002',
      equipmentId: 'A1024',
      entryDate: DateTime.now().subtract(const Duration(days: 2)),
      entryDetails: 'Cliente reporta ruido en fader canal 2. Ingresa con cable de poder.',
      diagnosis: 'Potenciómetro sucio y desgaste en fader.',
      status: 'In Progress',
    ),
  ];

  static final List<Message> inboxMessages = [
    Message(
      id: 'm1',
      senderName: 'Carlos Ruiz',
      platform: 'WhatsApp',
      content: 'Hola, me interesa alquilar el sistema RCF para este sábado.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Message(
      id: 'm2',
      senderName: '@dj_luisa',
      platform: 'Instagram',
      content: '¿Tienen repuestos para CDJ 2000?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Message(
      id: 'm3',
      senderName: '315 555 1234',
      platform: 'Phone',
      content: 'Llamada perdida',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
}
