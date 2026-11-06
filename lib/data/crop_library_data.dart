import '../models/crop_profile.dart';

const List<CropProfile> cropLibrary = <CropProfile>[
  CropProfile(
    id: 'almond', name: 'Almond', scientificName: 'Prunus dulcis', category: 'Tree crop', icon: 'almond', accentColor: 0xFF9B6A3B,
    description: 'A sun-loving orchard crop that needs deep, well-drained soil and a long warm season.', temperature: '25-35 C', exposure: 'Full sun', rainfall: '600-900 mm/year', humidity: '20-60%', watering: 'Intermediate', soil: 'Sandy, loamy', ph: '5.5-8', spacing: '6-7 m row / 3-5 m plant', companions: <String>['Lavender', 'Borage', 'Clover'], rotation: <String>['Cover crop', 'Legumes', 'Cereal crop'], nutrients: <String>['Nitrogen: 240 g/tree', 'Phosphorus: 70 g/tree', 'Potassium: 360 g/tree'],
  ),
  CropProfile(
    id: 'apple', name: 'Apple', scientificName: 'Malus domestica', category: 'Tree crop', icon: 'apple', accentColor: 0xFFC94D3B,
    description: 'A temperate fruit crop that performs best with winter chill, full sun, and reliable pollination.', temperature: '15-25 C', exposure: 'Full sun', rainfall: '500-1000 mm/year', humidity: '40-70%', watering: 'Intermediate', soil: 'Loamy, well-drained', ph: '6-7', spacing: '4-6 m row / 3-5 m plant', companions: <String>['Chives', 'Nasturtium', 'Dill'], rotation: <String>['Legumes', 'Cover crop', 'Orchard rest'], nutrients: <String>['Feed with compost yearly', 'Use potassium during fruiting', 'Avoid excess nitrogen'],
  ),
  CropProfile(
    id: 'banana', name: 'Banana', scientificName: 'Musa acuminata', category: 'Fruit crop', icon: 'banana', accentColor: 0xFFE8B63B,
    description: 'A tropical crop that needs warmth, moisture, wind protection, and rich organic soil.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '1200-2500 mm/year', humidity: '60-90%', watering: 'High', soil: 'Deep, fertile loam', ph: '5.5-7', spacing: '3 m row / 2-3 m plant', companions: <String>['Beans', 'Sweet potato', 'Marigold'], rotation: <String>['Legumes', 'Root crops', 'Green manure'], nutrients: <String>['High potassium during fruiting', 'Regular compost mulch', 'Split nitrogen applications'],
  ),
  CropProfile(
    id: 'barley', name: 'Barley', scientificName: 'Hordeum vulgare', category: 'Cereal', icon: 'barley', accentColor: 0xFFB99458,
    description: 'A cool-season cereal crop suited to fertile, well-drained fields and moderate irrigation.', temperature: '12-25 C', exposure: 'Full sun', rainfall: '450-900 mm/year', humidity: '40-70%', watering: 'Low', soil: 'Loam, sandy loam', ph: '6-7.5', spacing: '20 cm row / 5 cm plant', companions: <String>['Clover', 'Pea', 'Vetch'], rotation: <String>['Legume', 'Oilseed', 'Fallow cover'], nutrients: <String>['Balanced NPK before sowing', 'Avoid late excess nitrogen', 'Return straw where practical'],
  ),
  CropProfile(
    id: 'bean', name: 'Bean', scientificName: 'Phaseolus vulgaris', category: 'Legume', icon: 'bean', accentColor: 0xFF5B7A37,
    description: 'A nitrogen-fixing crop that prefers warm soil, good drainage, and steady moisture during flowering.', temperature: '18-30 C', exposure: 'Full sun', rainfall: '500-900 mm/year', humidity: '45-70%', watering: 'Intermediate', soil: 'Loamy, well-drained', ph: '6-7', spacing: '45 cm row / 10 cm plant', companions: <String>['Corn', 'Carrot', 'Cucumber'], rotation: <String>['Follow with cereal', 'Leafy greens', 'Root crop'], nutrients: <String>['Use compost at planting', 'Avoid heavy nitrogen', 'Add phosphorus for roots'],
  ),
  CropProfile(
    id: 'tomato', name: 'Tomato', scientificName: 'Solanum lycopersicum', category: 'Vegetable', icon: 'tomato', accentColor: 0xFFD4513A,
    description: 'A warm-season vegetable that needs strong light, fertile soil, and consistent watering at the root.', temperature: '20-30 C', exposure: 'Full sun', rainfall: '600-1200 mm/year', humidity: '50-70%', watering: 'Intermediate', soil: 'Fertile loam', ph: '6-6.8', spacing: '90 cm row / 45 cm plant', companions: <String>['Basil', 'Carrot', 'Marigold'], rotation: <String>['Beans', 'Cereal', 'Leafy greens'], nutrients: <String>['Compost before planting', 'Calcium for steady growth', 'Potassium during fruiting'],
  ),
  CropProfile(
    id: 'rice', name: 'Rice', scientificName: 'Oryza sativa', category: 'Cereal', icon: 'rice', accentColor: 0xFF7C9D54,
    description: 'A warm-season cereal that needs dependable water management and nutrient-rich field soil.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '1000-2000 mm/year', humidity: '60-90%', watering: 'High', soil: 'Clay loam', ph: '5.5-6.5', spacing: '20 cm row / 15 cm plant', companions: <String>['Azolla', 'Sesbania', 'Duckweed'], rotation: <String>['Legume', 'Vegetable', 'Green manure'], nutrients: <String>['Split nitrogen feeding', 'Phosphorus at establishment', 'Potassium before flowering'],
  ),
  CropProfile(
    id: 'wheat', name: 'Wheat', scientificName: 'Triticum aestivum', category: 'Cereal', icon: 'wheat', accentColor: 0xFFD0A84B,
    description: 'A cool-season cereal crop that needs a firm seedbed, good drainage, and balanced nutrition.', temperature: '12-25 C', exposure: 'Full sun', rainfall: '450-900 mm/year', humidity: '40-65%', watering: 'Low', soil: 'Fertile loam', ph: '6-7.5', spacing: '20 cm row / 5 cm plant', companions: <String>['Clover', 'Pea', 'Vetch'], rotation: <String>['Legume', 'Oilseed', 'Root crop'], nutrients: <String>['Nitrogen in split doses', 'Phosphorus at sowing', 'Potassium on light soils'],
  ),
  CropProfile(
    id: 'maize', name: 'Maize', scientificName: 'Zea mays', category: 'Cereal', icon: 'maize', accentColor: 0xFFE1B43C,
    description: 'A warm-season cereal crop that needs fertile soil, sunshine, and regular moisture during flowering.', temperature: '18-32 C', exposure: 'Full sun', rainfall: '500-800 mm/season', humidity: '45-75%', watering: 'Intermediate', soil: 'Deep, well-drained loam', ph: '5.5-7.5', spacing: '60 cm row / 20 cm plant', companions: <String>['Bean', 'Cucumber', 'Pumpkin'], rotation: <String>['Legume', 'Oilseed', 'Vegetable'], nutrients: <String>['Nitrogen in split doses', 'Phosphorus at sowing', 'Potassium before tasseling'],
  ),
  CropProfile(
    id: 'cotton', name: 'Cotton', scientificName: 'Gossypium hirsutum', category: 'Fiber crop', icon: 'cotton', accentColor: 0xFFB7A77A,
    description: 'A long-season fiber crop that prefers warm weather, deep soil, and careful water management.', temperature: '21-35 C', exposure: 'Full sun', rainfall: '500-1000 mm/season', humidity: '40-70%', watering: 'Intermediate', soil: 'Deep black or loamy soil', ph: '5.5-8', spacing: '90 cm row / 45 cm plant', companions: <String>['Pigeon pea', 'Cowpea', 'Sorghum'], rotation: <String>['Legume', 'Cereal', 'Green manure'], nutrients: <String>['Soil-test-based nitrogen', 'Potassium during boll formation', 'Add organic matter'],
  ),
  CropProfile(
    id: 'sugarcane', name: 'Sugarcane', scientificName: 'Saccharum officinarum', category: 'Commercial crop', icon: 'sugarcane', accentColor: 0xFF6D9B55,
    description: 'A tall tropical crop requiring a long warm season, fertile soil, and consistent irrigation.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '1000-1500 mm/year', humidity: '60-85%', watering: 'High', soil: 'Deep fertile loam', ph: '6-7.5', spacing: '120 cm row / 30 cm setts', companions: <String>['Legumes', 'Onion', 'Potato'], rotation: <String>['Legume', 'Rice', 'Green manure'], nutrients: <String>['Compost or manure before planting', 'Split nitrogen applications', 'Potassium for stalk strength'],
  ),
  CropProfile(
    id: 'mustard', name: 'Mustard', scientificName: 'Brassica juncea', category: 'Oilseed', icon: 'mustard', accentColor: 0xFFE5BE3B,
    description: 'A cool-season oilseed crop that grows well in sunny fields with moderate irrigation.', temperature: '10-25 C', exposure: 'Full sun', rainfall: '350-500 mm/season', humidity: '35-65%', watering: 'Low', soil: 'Loam to clay loam', ph: '6-7.5', spacing: '30 cm row / 10 cm plant', companions: <String>['Pea', 'Clover', 'Coriander'], rotation: <String>['Cereal', 'Legume', 'Fallow cover'], nutrients: <String>['Sulfur supports oil quality', 'Nitrogen before flowering', 'Phosphorus at sowing'],
  ),
  CropProfile(
    id: 'groundnut', name: 'Groundnut', scientificName: 'Arachis hypogaea', category: 'Oilseed legume', icon: 'groundnut', accentColor: 0xFFC88C4A,
    description: 'A warm-season legume that needs loose soil, sunshine, and even moisture during pegging.', temperature: '22-30 C', exposure: 'Full sun', rainfall: '500-1000 mm/season', humidity: '45-70%', watering: 'Intermediate', soil: 'Loose sandy loam', ph: '6-7.5', spacing: '30 cm row / 10 cm plant', companions: <String>['Millet', 'Maize', 'Sesame'], rotation: <String>['Cereal', 'Cotton', 'Leafy greens'], nutrients: <String>['Calcium near pegging', 'Phosphorus for root growth', 'Avoid excess nitrogen'],
  ),
  CropProfile(
    id: 'chickpea', name: 'Chickpea', scientificName: 'Cicer arietinum', category: 'Pulse', icon: 'chickpea', accentColor: 0xFFD2B27A,
    description: 'A cool-season pulse crop that prefers dry weather, well-drained soil, and limited standing water.', temperature: '15-30 C', exposure: 'Full sun', rainfall: '400-700 mm/season', humidity: '35-60%', watering: 'Low', soil: 'Sandy loam', ph: '6-8', spacing: '30 cm row / 10 cm plant', companions: <String>['Wheat', 'Mustard', 'Coriander'], rotation: <String>['Cereal', 'Oilseed', 'Vegetable'], nutrients: <String>['Use inoculated seed where suitable', 'Phosphorus at sowing', 'Avoid excess nitrogen'],
  ),
  CropProfile(
    id: 'pigeon-pea', name: 'Pigeon Pea', scientificName: 'Cajanus cajan', category: 'Pulse', icon: 'pigeon-pea', accentColor: 0xFFB9954A,
    description: 'A resilient warm-season pulse crop that tolerates dry periods and improves soil through nitrogen fixation.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '600-1000 mm/season', humidity: '40-70%', watering: 'Low', soil: 'Well-drained loam', ph: '5-8', spacing: '90 cm row / 20 cm plant', companions: <String>['Sorghum', 'Millet', 'Groundnut'], rotation: <String>['Cereal', 'Cotton', 'Oilseed'], nutrients: <String>['Use compost before sowing', 'Phosphorus for establishment', 'Avoid heavy nitrogen'],
  ),
  CropProfile(
    id: 'lentil', name: 'Lentil', scientificName: 'Lens culinaris', category: 'Pulse', icon: 'lentil', accentColor: 0xFF9E7D52,
    description: 'A cool-season pulse crop suited to moderate rainfall, light soil, and a dry harvest period.', temperature: '15-25 C', exposure: 'Full sun', rainfall: '350-550 mm/season', humidity: '35-60%', watering: 'Low', soil: 'Sandy loam', ph: '6-8', spacing: '25 cm row / 8 cm plant', companions: <String>['Wheat', 'Barley', 'Mustard'], rotation: <String>['Cereal', 'Oilseed', 'Vegetable'], nutrients: <String>['Phosphorus at sowing', 'Use healthy inoculated seed', 'Avoid excess nitrogen'],
  ),
  CropProfile(
    id: 'potato', name: 'Potato', scientificName: 'Solanum tuberosum', category: 'Vegetable', icon: 'potato', accentColor: 0xFFC69A58,
    description: 'A cool-season tuber crop that needs loose soil, regular moisture, and protection from heat.', temperature: '15-25 C', exposure: 'Full sun', rainfall: '500-750 mm/season', humidity: '50-75%', watering: 'Intermediate', soil: 'Loose sandy loam', ph: '5-6.5', spacing: '60 cm row / 20 cm plant', companions: <String>['Bean', 'Cabbage', 'Marigold'], rotation: <String>['Legume', 'Cereal', 'Green manure'], nutrients: <String>['Potassium supports tubers', 'Compost before planting', 'Hill soil around plants'],
  ),
  CropProfile(
    id: 'onion', name: 'Onion', scientificName: 'Allium cepa', category: 'Vegetable', icon: 'onion', accentColor: 0xFFC48776,
    description: 'A bulb crop that needs sunshine, fertile well-drained soil, and steady moisture during bulb formation.', temperature: '13-30 C', exposure: 'Full sun', rainfall: '500-700 mm/season', humidity: '40-65%', watering: 'Intermediate', soil: 'Sandy loam', ph: '6-7.5', spacing: '20 cm row / 10 cm plant', companions: <String>['Carrot', 'Beet', 'Lettuce'], rotation: <String>['Cereal', 'Legume', 'Leafy greens'], nutrients: <String>['Sulfur supports bulb quality', 'Split nitrogen early', 'Reduce nitrogen near maturity'],
  ),
  CropProfile(
    id: 'chilli', name: 'Chilli', scientificName: 'Capsicum annuum', category: 'Spice vegetable', icon: 'chilli', accentColor: 0xFFD74D36,
    description: 'A warm-season spice crop that needs full sun, fertile soil, and consistent root-zone moisture.', temperature: '20-32 C', exposure: 'Full sun', rainfall: '600-1200 mm/season', humidity: '50-75%', watering: 'Intermediate', soil: 'Fertile loam', ph: '6-7', spacing: '60 cm row / 45 cm plant', companions: <String>['Basil', 'Carrot', 'Onion'], rotation: <String>['Legume', 'Cereal', 'Root crop'], nutrients: <String>['Compost before transplanting', 'Potassium during fruiting', 'Calcium supports healthy growth'],
  ),
  CropProfile(
    id: 'turmeric', name: 'Turmeric', scientificName: 'Curcuma longa', category: 'Spice crop', icon: 'turmeric', accentColor: 0xFFE5A52E,
    description: 'A warm, moisture-loving rhizome crop that prefers filtered light, rich soil, and good drainage.', temperature: '20-35 C', exposure: 'Full sun to partial shade', rainfall: '1000-2000 mm/year', humidity: '60-90%', watering: 'High', soil: 'Rich, well-drained loam', ph: '5-7.5', spacing: '45 cm row / 20 cm plant', companions: <String>['Coconut', 'Pigeon pea', 'Beans'], rotation: <String>['Legume', 'Cereal', 'Green manure'], nutrients: <String>['Compost or manure before planting', 'Potassium during rhizome filling', 'Mulch to retain moisture'],
  ),
  CropProfile(
    id: 'mango', name: 'Mango', scientificName: 'Mangifera indica', category: 'Fruit tree', icon: 'mango', accentColor: 0xFFE7A92F,
    description: 'A warm-climate fruit tree that needs full sun, deep soil, and a dry period before flowering.', temperature: '24-35 C', exposure: 'Full sun', rainfall: '750-2500 mm/year', humidity: '45-80%', watering: 'Intermediate', soil: 'Deep, well-drained loam', ph: '5.5-7.5', spacing: '8-10 m row / 8-10 m plant', companions: <String>['Coconut', 'Legumes', 'Marigold'], rotation: <String>['Orchard cover', 'Legumes', 'Green manure'], nutrients: <String>['Compost after harvest', 'Potassium during fruiting', 'Avoid excess nitrogen before flowering'],
  ),
  CropProfile(
    id: 'coconut', name: 'Coconut', scientificName: 'Cocos nucifera', category: 'Plantation crop', icon: 'coconut', accentColor: 0xFF4E8B55,
    description: 'A tropical plantation crop that needs warmth, moisture, sunlight, and free-draining soil.', temperature: '22-32 C', exposure: 'Full sun', rainfall: '1300-2500 mm/year', humidity: '70-90%', watering: 'High', soil: 'Sandy loam', ph: '5.5-8', spacing: '7.5 m row / 7.5 m plant', companions: <String>['Banana', 'Turmeric', 'Black pepper'], rotation: <String>['Legume cover', 'Green manure', 'Intercrop'], nutrients: <String>['Organic mulch around basin', 'Potassium for nut development', 'Balanced micronutrients'],
  ),
  CropProfile(
    id: 'soybean', name: 'Soybean', scientificName: 'Glycine max', category: 'Oilseed legume', icon: 'soybean', accentColor: 0xFF9A9C4A,
    description: 'A warm-season legume that grows best in fertile, well-drained soil with regular moisture.', temperature: '20-30 C', exposure: 'Full sun', rainfall: '500-900 mm/season', humidity: '45-75%', watering: 'Intermediate', soil: 'Loamy, well-drained', ph: '6-7.5', spacing: '45 cm row / 5 cm plant', companions: <String>['Maize', 'Sorghum', 'Sesame'], rotation: <String>['Cereal', 'Wheat', 'Vegetable'], nutrients: <String>['Use suitable seed inoculation', 'Phosphorus at sowing', 'Avoid excess nitrogen'],
  ),
  CropProfile(
    id: 'sunflower', name: 'Sunflower', scientificName: 'Helianthus annuus', category: 'Oilseed', icon: 'sunflower', accentColor: 0xFFE2B52E,
    description: 'A hardy oilseed crop that needs full sun, moderate water, and deep soil for strong roots.', temperature: '18-30 C', exposure: 'Full sun', rainfall: '400-700 mm/season', humidity: '35-65%', watering: 'Intermediate', soil: 'Deep loam', ph: '6-7.5', spacing: '45 cm row / 20 cm plant', companions: <String>['Bean', 'Cucumber', 'Basil'], rotation: <String>['Cereal', 'Legume', 'Green manure'], nutrients: <String>['Nitrogen before flowering', 'Boron where soil tests require it', 'Potassium during seed filling'],
  ),
  CropProfile(
    id: 'sesame', name: 'Sesame', scientificName: 'Sesamum indicum', category: 'Oilseed', icon: 'sesame', accentColor: 0xFFB98C50,
    description: 'A warm-season oilseed crop suited to light soil, sunshine, and low to moderate irrigation.', temperature: '25-35 C', exposure: 'Full sun', rainfall: '400-650 mm/season', humidity: '35-65%', watering: 'Low', soil: 'Sandy loam', ph: '5.5-8', spacing: '30 cm row / 10 cm plant', companions: <String>['Groundnut', 'Pigeon pea', 'Millet'], rotation: <String>['Cereal', 'Legume', 'Cotton'], nutrients: <String>['Phosphorus at sowing', 'Sulfur supports seed quality', 'Avoid waterlogging'],
  ),
  CropProfile(
    id: 'sorghum', name: 'Sorghum', scientificName: 'Sorghum bicolor', category: 'Cereal', icon: 'sorghum', accentColor: 0xFFAA8148,
    description: 'A drought-tolerant cereal crop that performs well in warm regions with moderate rainfall.', temperature: '25-35 C', exposure: 'Full sun', rainfall: '400-750 mm/season', humidity: '35-65%', watering: 'Low', soil: 'Loam to clay loam', ph: '5.5-8', spacing: '45 cm row / 15 cm plant', companions: <String>['Pigeon pea', 'Bean', 'Groundnut'], rotation: <String>['Legume', 'Oilseed', 'Vegetable'], nutrients: <String>['Nitrogen in split doses', 'Phosphorus at sowing', 'Organic matter improves water holding'],
  ),
  CropProfile(
    id: 'pearl-millet', name: 'Pearl Millet', scientificName: 'Cenchrus americanus', category: 'Cereal', icon: 'pearl-millet', accentColor: 0xFFC5A25B,
    description: 'A heat- and drought-tolerant cereal crop suited to light soils and dry farming regions.', temperature: '25-35 C', exposure: 'Full sun', rainfall: '300-600 mm/season', humidity: '30-60%', watering: 'Low', soil: 'Sandy loam', ph: '6-8', spacing: '45 cm row / 15 cm plant', companions: <String>['Groundnut', 'Pigeon pea', 'Cowpea'], rotation: <String>['Legume', 'Oilseed', 'Vegetable'], nutrients: <String>['Compost before sowing', 'Nitrogen early in growth', 'Potassium supports drought tolerance'],
  ),
  CropProfile(
    id: 'okra', name: 'Okra', scientificName: 'Abelmoschus esculentus', category: 'Vegetable', icon: 'okra', accentColor: 0xFF6A9B4A,
    description: 'A warm-season vegetable that needs full sun, fertile soil, and regular picking for continued production.', temperature: '24-35 C', exposure: 'Full sun', rainfall: '600-1200 mm/season', humidity: '50-80%', watering: 'Intermediate', soil: 'Fertile loam', ph: '6-7.5', spacing: '45 cm row / 30 cm plant', companions: <String>['Basil', 'Pepper', 'Marigold'], rotation: <String>['Cereal', 'Legume', 'Root crop'], nutrients: <String>['Compost before planting', 'Balanced nitrogen early', 'Potassium during pod production'],
  ),
  CropProfile(
    id: 'brinjal', name: 'Brinjal', scientificName: 'Solanum melongena', category: 'Vegetable', icon: 'brinjal', accentColor: 0xFF75519B,
    description: 'A warm-season vegetable that prefers fertile soil, full sun, and steady moisture without waterlogging.', temperature: '22-32 C', exposure: 'Full sun', rainfall: '600-1200 mm/season', humidity: '50-80%', watering: 'Intermediate', soil: 'Fertile loam', ph: '5.5-6.8', spacing: '60 cm row / 45 cm plant', companions: <String>['Bean', 'Basil', 'Marigold'], rotation: <String>['Cereal', 'Legume', 'Leafy greens'], nutrients: <String>['Compost before transplanting', 'Potassium during fruiting', 'Mulch to maintain even moisture'],
  ),
  CropProfile(
    id: 'cauliflower', name: 'Cauliflower', scientificName: 'Brassica oleracea var. botrytis', category: 'Vegetable', icon: 'cauliflower', accentColor: 0xFFD8D6BF,
    description: 'A cool-season vegetable that needs fertile soil, consistent moisture, and mild temperatures for good curds.', temperature: '15-25 C', exposure: 'Full sun', rainfall: '500-1000 mm/season', humidity: '50-75%', watering: 'Intermediate', soil: 'Moist, fertile loam', ph: '6-7.5', spacing: '45 cm row / 45 cm plant', companions: <String>['Dill', 'Celery', 'Onion'], rotation: <String>['Legume', 'Cereal', 'Root crop'], nutrients: <String>['Compost before planting', 'Nitrogen during leaf growth', 'Boron only where soil tests indicate need'],
  ),
];

const List<CropProfile> floweringPlantLibrary = <CropProfile>[
  CropProfile(
    id: 'rose', name: 'Rose', scientificName: 'Rosa spp.', category: 'Flowering shrub', icon: 'rose', accentColor: 0xFFD94B5B,
    description: 'A popular flowering shrub that needs sunlight, fertile soil, regular pruning, and good air circulation.', temperature: '15-30 C', exposure: 'Full sun', rainfall: '600-1200 mm/year', humidity: '45-75%', watering: 'Intermediate', soil: 'Rich, well-drained loam', ph: '6-7', spacing: '60-90 cm plant to plant', companions: <String>['Lavender', 'Marigold', 'Basil'], rotation: <String>['Leafy greens', 'Legumes', 'Cover crop'], nutrients: <String>['Compost in growing season', 'Balanced feed during flowering', 'Potassium for blooms'],
  ),
  CropProfile(
    id: 'jasmine', name: 'Jasmine', scientificName: 'Jasminum sambac', category: 'Flowering shrub', icon: 'jasmine', accentColor: 0xFFF1E4B8,
    description: 'A fragrant flowering shrub that prefers warmth, bright light, and soil that drains freely.', temperature: '18-32 C', exposure: 'Full sun to partial shade', rainfall: '700-1500 mm/year', humidity: '50-80%', watering: 'Intermediate', soil: 'Loamy, well-drained', ph: '6-7.5', spacing: '1-1.5 m plant to plant', companions: <String>['Tulsi', 'Marigold', 'Lemongrass'], rotation: <String>['Compost cover', 'Legumes', 'Ground cover'], nutrients: <String>['Compost after pruning', 'Balanced feed monthly', 'Potassium during flowering'],
  ),
  CropProfile(
    id: 'marigold', name: 'Marigold', scientificName: 'Tagetes erecta', category: 'Annual flower', icon: 'marigold', accentColor: 0xFFE7A52D,
    description: 'A hardy annual flower suited to warm weather, full sun, and moderate watering.', temperature: '18-32 C', exposure: 'Full sun', rainfall: '500-1000 mm/year', humidity: '40-75%', watering: 'Intermediate', soil: 'Loamy, well-drained', ph: '6-7.5', spacing: '30-45 cm plant to plant', companions: <String>['Tomato', 'Chilli', 'Basil'], rotation: <String>['Vegetable crop', 'Legume', 'Green manure'], nutrients: <String>['Compost before planting', 'Avoid excess nitrogen', 'Phosphorus for root growth'],
  ),
  CropProfile(
    id: 'hibiscus', name: 'Hibiscus', scientificName: 'Hibiscus rosa-sinensis', category: 'Flowering shrub', icon: 'hibiscus', accentColor: 0xFFE15B62,
    description: 'A warm-climate flowering shrub that blooms best with sunlight, moisture, and regular trimming.', temperature: '18-35 C', exposure: 'Full sun', rainfall: '800-2000 mm/year', humidity: '50-85%', watering: 'Intermediate', soil: 'Fertile loam', ph: '6-7.5', spacing: '1-1.5 m plant to plant', companions: <String>['Jasmine', 'Marigold', 'Aloe vera'], rotation: <String>['Organic mulch', 'Legume cover', 'Ground cover'], nutrients: <String>['Compost regularly', 'Potassium during flowering', 'Micronutrient feed when needed'],
  ),
  CropProfile(
    id: 'lotus', name: 'Lotus', scientificName: 'Nelumbo nucifera', category: 'Aquatic flower', icon: 'lotus', accentColor: 0xFFE69AA9,
    description: 'An aquatic flowering plant that needs warm water, strong sunlight, and a wide container or pond.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '800-2000 mm/year', humidity: '60-90%', watering: 'High', soil: 'Heavy loam or clay soil', ph: '6-8', spacing: '1-2 m plant to plant', companions: <String>['Water lily', 'Aquatic grasses', 'Water plants'], rotation: <String>['Pond rest', 'Organic sediment', 'Container refresh'], nutrients: <String>['Use aquatic plant fertilizer', 'Feed during active growth', 'Avoid excess algae nutrients'],
  ),
  CropProfile(
    id: 'chrysanthemum', name: 'Chrysanthemum', scientificName: 'Chrysanthemum morifolium', category: 'Annual flower', icon: 'chrysanthemum', accentColor: 0xFFE7B83E,
    description: 'A cool-season ornamental flower that benefits from bright light, pinching, and well-drained soil.', temperature: '12-25 C', exposure: 'Full sun', rainfall: '500-900 mm/year', humidity: '45-70%', watering: 'Intermediate', soil: 'Fertile loam', ph: '6-7', spacing: '30-45 cm plant to plant', companions: <String>['Alyssum', 'Basil', 'Marigold'], rotation: <String>['Legume', 'Leafy greens', 'Compost cover'], nutrients: <String>['Compost before planting', 'Balanced feed during growth', 'Potassium before blooming'],
  ),
  CropProfile(
    id: 'bougainvillea', name: 'Bougainvillea', scientificName: 'Bougainvillea glabra', category: 'Flowering climber', icon: 'bougainvillea', accentColor: 0xFFD65B9D,
    description: 'A drought-tolerant flowering climber that produces more color in bright sun and lean, well-drained soil.', temperature: '18-35 C', exposure: 'Full sun', rainfall: '500-1200 mm/year', humidity: '35-75%', watering: 'Low', soil: 'Sandy, well-drained', ph: '5.5-7.5', spacing: '1.5-3 m plant to plant', companions: <String>['Aloe vera', 'Lavender', 'Rosemary'], rotation: <String>['Organic mulch', 'Ground cover', 'Compost rest'], nutrients: <String>['Avoid excess nitrogen', 'Phosphorus during flowering', 'Compost after pruning'],
  ),
  CropProfile(
    id: 'orchid', name: 'Orchid', scientificName: 'Orchidaceae', category: 'Ornamental flower', icon: 'orchid', accentColor: 0xFFB77AC8,
    description: 'An ornamental flower that prefers filtered light, high humidity, airflow, and a loose growing medium.', temperature: '18-30 C', exposure: 'Bright indirect light', rainfall: '1000-2500 mm/year', humidity: '60-85%', watering: 'Intermediate', soil: 'Bark, moss, or airy medium', ph: '5.5-6.5', spacing: '30-45 cm plant to plant', companions: <String>['Ferns', 'Bromeliads', 'Peace lily'], rotation: <String>['Fresh potting medium', 'Root rest', 'Organic mulch'], nutrients: <String>['Diluted orchid feed', 'Feed during active growth', 'Flush medium periodically'],
  ),
  CropProfile(
    id: 'tuberose', name: 'Tuberose', scientificName: 'Polianthes tuberosa', category: 'Bulb flower', icon: 'tuberose', accentColor: 0xFFF6F0D8,
    description: 'A fragrant bulb flower that needs warmth, sunlight, loose soil, and careful drainage.', temperature: '20-32 C', exposure: 'Full sun', rainfall: '600-1200 mm/year', humidity: '45-75%', watering: 'Intermediate', soil: 'Sandy loam', ph: '6.5-7.5', spacing: '30 cm row / 20 cm plant', companions: <String>['Marigold', 'Basil', 'Lemongrass'], rotation: <String>['Legume', 'Cereal', 'Green manure'], nutrients: <String>['Compost before planting', 'Phosphorus for bulbs', 'Potassium during flowering'],
  ),
  CropProfile(
    id: 'gerbera', name: 'Gerbera', scientificName: 'Gerbera jamesonii', category: 'Ornamental flower', icon: 'gerbera', accentColor: 0xFFE76D48,
    description: 'A colorful ornamental flower that needs bright light, excellent drainage, and moderate feeding.', temperature: '15-28 C', exposure: 'Full sun to partial shade', rainfall: '600-1000 mm/year', humidity: '45-70%', watering: 'Intermediate', soil: 'Sandy, well-drained loam', ph: '5.5-6.5', spacing: '30-45 cm plant to plant', companions: <String>['Marigold', 'Alyssum', 'Basil'], rotation: <String>['Legume', 'Leafy greens', 'Soil rest'], nutrients: <String>['Compost before planting', 'Balanced feed during growth', 'Calcium supports strong stems'],
  ),
  CropProfile(
    id: 'zinnia', name: 'Zinnia', scientificName: 'Zinnia elegans', category: 'Annual flower', icon: 'zinnia', accentColor: 0xFFE15D79,
    description: 'An easy annual flower for warm climates that rewards full sun, airflow, and regular deadheading.', temperature: '18-32 C', exposure: 'Full sun', rainfall: '500-1000 mm/year', humidity: '40-70%', watering: 'Low', soil: 'Loamy, well-drained', ph: '5.5-7.5', spacing: '20-30 cm plant to plant', companions: <String>['Tomato', 'Basil', 'Marigold'], rotation: <String>['Legume', 'Cereal', 'Cover crop'], nutrients: <String>['Compost before sowing', 'Avoid excess nitrogen', 'Light feed during flowering'],
  ),
  CropProfile(
    id: 'petunia', name: 'Petunia', scientificName: 'Petunia x hybrida', category: 'Annual flower', icon: 'petunia', accentColor: 0xFF8A6BC4,
    description: 'A colorful bedding flower that prefers mild weather, bright light, and fertile containers with drainage.', temperature: '12-28 C', exposure: 'Full sun', rainfall: '500-900 mm/year', humidity: '40-70%', watering: 'Intermediate', soil: 'Fertile, well-drained potting mix', ph: '5.5-6.5', spacing: '20-30 cm plant to plant', companions: <String>['Gerbera', 'Marigold', 'Alyssum'], rotation: <String>['Fresh potting mix', 'Legume cover', 'Soil rest'], nutrients: <String>['Regular diluted flower feed', 'Phosphorus during blooming', 'Remove faded flowers'],
  ),
  CropProfile(
    id: 'ixora', name: 'Ixora', scientificName: 'Ixora coccinea', category: 'Flowering shrub', icon: 'ixora', accentColor: 0xFFE95A4F,
    description: 'A tropical evergreen shrub with clustered flowers that needs warmth, humidity, and acidic soil.', temperature: '20-35 C', exposure: 'Full sun to partial shade', rainfall: '1000-2500 mm/year', humidity: '60-90%', watering: 'Intermediate', soil: 'Acidic, well-drained loam', ph: '5-6.5', spacing: '1-1.5 m plant to plant', companions: <String>['Jasmine', 'Hibiscus', 'Ferns'], rotation: <String>['Organic mulch', 'Legume cover', 'Compost rest'], nutrients: <String>['Acid-loving plant feed', 'Compost around roots', 'Potassium during flowering'],
  ),
  CropProfile(
    id: 'plumeria', name: 'Plumeria', scientificName: 'Plumeria rubra', category: 'Flowering tree', icon: 'plumeria', accentColor: 0xFFF3D39A,
    description: 'A fragrant flowering tree that thrives in warm sun, dry periods, and free-draining soil.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '700-1800 mm/year', humidity: '45-80%', watering: 'Low', soil: 'Sandy, well-drained', ph: '6-7.5', spacing: '3-5 m plant to plant', companions: <String>['Aloe vera', 'Marigold', 'Lemongrass'], rotation: <String>['Tree cover', 'Legumes', 'Organic mulch'], nutrients: <String>['Compost after pruning', 'Potassium before flowering', 'Avoid excess water in cool season'],
  ),
  CropProfile(
    id: 'lavender', name: 'Lavender', scientificName: 'Lavandula angustifolia', category: 'Aromatic flower', icon: 'lavender', accentColor: 0xFF9B7BC2,
    description: 'An aromatic flowering plant that needs strong light, low humidity, and very well-drained soil.', temperature: '12-30 C', exposure: 'Full sun', rainfall: '300-800 mm/year', humidity: '30-60%', watering: 'Low', soil: 'Sandy, sharply drained', ph: '6.5-8', spacing: '45-60 cm plant to plant', companions: <String>['Rose', 'Rosemary', 'Thyme'], rotation: <String>['Cereal', 'Legume', 'Dry cover crop'], nutrients: <String>['Light compost only', 'Avoid rich nitrogen feed', 'Potassium during flowering'],
  ),
  CropProfile(
    id: 'dahlia', name: 'Dahlia', scientificName: 'Dahlia pinnata', category: 'Tuber flower', icon: 'dahlia', accentColor: 0xFFD95775,
    description: 'A showy tuber flower that needs sunlight, fertile soil, regular watering, and support for tall stems.', temperature: '15-28 C', exposure: 'Full sun', rainfall: '600-1200 mm/year', humidity: '45-70%', watering: 'Intermediate', soil: 'Fertile, well-drained loam', ph: '6-7.5', spacing: '45-60 cm plant to plant', companions: <String>['Marigold', 'Basil', 'Rosemary'], rotation: <String>['Legume', 'Cereal', 'Green manure'], nutrients: <String>['Compost before planting', 'Phosphorus for roots', 'Potassium during bloom production'],
  ),
  CropProfile(
    id: 'tulip', name: 'Tulip', scientificName: 'Tulipa gesneriana', category: 'Bulb flower', icon: 'tulip', accentColor: 0xFFE56E6E,
    description: 'A cool-season bulb flower that needs a mild winter, bright light, and soil that drains quickly.', temperature: '5-22 C', exposure: 'Full sun', rainfall: '400-800 mm/year', humidity: '40-65%', watering: 'Low', soil: 'Sandy, well-drained', ph: '6-7', spacing: '10-15 cm plant to plant', companions: <String>['Pansy', 'Alyssum', 'Dianthus'], rotation: <String>['Legume', 'Leafy greens', 'Soil rest'], nutrients: <String>['Bulb feed at planting', 'Avoid excess nitrogen', 'Allow foliage to mature after flowering'],
  ),
  CropProfile(
    id: 'periwinkle', name: 'Periwinkle', scientificName: 'Catharanthus roseus', category: 'Flowering ground cover', icon: 'periwinkle', accentColor: 0xFFB875B8,
    description: 'A heat-tolerant flowering ground cover that grows well in sunny beds and moderate soils.', temperature: '20-35 C', exposure: 'Full sun to partial shade', rainfall: '600-1500 mm/year', humidity: '45-80%', watering: 'Low', soil: 'Sandy, well-drained', ph: '6-8', spacing: '30-45 cm plant to plant', companions: <String>['Marigold', 'Aloe vera', 'Lemongrass'], rotation: <String>['Cereal', 'Legume', 'Organic mulch'], nutrients: <String>['Compost before planting', 'Light balanced feed', 'Avoid waterlogging'],
  ),
  CropProfile(
    id: 'sunflower-flower', name: 'Sunflower', scientificName: 'Helianthus annuus', category: 'Annual flower', icon: 'sunflower-flower', accentColor: 0xFFE4B72F,
    description: 'A tall annual flower that needs full sun, deep soil, and regular water while the stem and head develop.', temperature: '18-32 C', exposure: 'Full sun', rainfall: '500-900 mm/season', humidity: '35-70%', watering: 'Intermediate', soil: 'Deep, fertile loam', ph: '6-7.5', spacing: '45-60 cm plant to plant', companions: <String>['Bean', 'Cucumber', 'Marigold'], rotation: <String>['Legume', 'Cereal', 'Green manure'], nutrients: <String>['Compost before sowing', 'Nitrogen early in growth', 'Potassium during seed formation'],
  ),
  CropProfile(
    id: 'cosmos', name: 'Cosmos', scientificName: 'Cosmos bipinnatus', category: 'Annual flower', icon: 'cosmos', accentColor: 0xFFE09AB4,
    description: 'A low-maintenance annual flower that performs well in sunny locations and moderately fertile soil.', temperature: '18-32 C', exposure: 'Full sun', rainfall: '500-1000 mm/year', humidity: '40-70%', watering: 'Low', soil: 'Loamy, well-drained', ph: '6-7.5', spacing: '30-45 cm plant to plant', companions: <String>['Basil', 'Marigold', 'Vegetables'], rotation: <String>['Legume', 'Cereal', 'Cover crop'], nutrients: <String>['Light compost before planting', 'Avoid excess nitrogen', 'Deadhead for more flowers'],
  ),
  CropProfile(
    id: 'night-flowering-jasmine', name: 'Night-flowering Jasmine', scientificName: 'Nyctanthes arbor-tristis', category: 'Flowering tree', icon: 'night-jasmine', accentColor: 0xFFF2A44E,
    description: 'A fragrant Indian flowering tree that prefers warmth, morning sun, and soil with reliable drainage.', temperature: '18-35 C', exposure: 'Full sun to partial shade', rainfall: '700-1600 mm/year', humidity: '50-85%', watering: 'Intermediate', soil: 'Loamy, well-drained', ph: '6-7.5', spacing: '3-5 m plant to plant', companions: <String>['Jasmine', 'Tulsi', 'Marigold'], rotation: <String>['Organic mulch', 'Legume cover', 'Tree rest'], nutrients: <String>['Compost twice yearly', 'Balanced feed after pruning', 'Potassium during flowering'],
  ),
  CropProfile(
    id: 'butterfly-pea', name: 'Butterfly Pea', scientificName: 'Clitoria ternatea', category: 'Flowering climber', icon: 'butterfly-pea', accentColor: 0xFF6374C8,
    description: 'A hardy Indian climber with blue flowers that enjoys warmth, sunlight, and support for its vines.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '600-1500 mm/year', humidity: '45-85%', watering: 'Low', soil: 'Loamy, well-drained', ph: '5.5-8', spacing: '30-60 cm plant to plant', companions: <String>['Marigold', 'Lemongrass', 'Basil'], rotation: <String>['Cereal', 'Vegetable', 'Green manure'], nutrients: <String>['Compost before planting', 'Light balanced feed', 'Avoid waterlogging'],
  ),
  CropProfile(
    id: 'champa', name: 'Champa', scientificName: 'Magnolia champaca', category: 'Flowering tree', icon: 'champa', accentColor: 0xFFE6B342,
    description: 'A fragrant tropical tree that needs warmth, sunlight, deep soil, and space for its canopy.', temperature: '20-35 C', exposure: 'Full sun to partial shade', rainfall: '1000-2500 mm/year', humidity: '60-90%', watering: 'Intermediate', soil: 'Deep, fertile loam', ph: '5.5-7.5', spacing: '5-8 m plant to plant', companions: <String>['Jasmine', 'Tulsi', 'Ground cover'], rotation: <String>['Organic mulch', 'Legume cover', 'Tree rest'], nutrients: <String>['Compost twice yearly', 'Balanced feed after pruning', 'Potassium during flowering'],
  ),
  CropProfile(
    id: 'gulmohar', name: 'Gulmohar', scientificName: 'Delonix regia', category: 'Flowering tree', icon: 'gulmohar', accentColor: 0xFFE35A35,
    description: 'A broad-canopy flowering tree suited to warm regions, open sunlight, and well-drained soil.', temperature: '20-35 C', exposure: 'Full sun', rainfall: '700-1800 mm/year', humidity: '45-80%', watering: 'Low', soil: 'Sandy loam', ph: '6-8', spacing: '8-12 m plant to plant', companions: <String>['Aloe vera', 'Marigold', 'Lawn grass'], rotation: <String>['Tree cover', 'Legume cover', 'Organic mulch'], nutrients: <String>['Compost during active growth', 'Balanced feed yearly', 'Avoid standing water'],
  ),
  CropProfile(
    id: 'oleander', name: 'Oleander', scientificName: 'Nerium oleander', category: 'Flowering shrub', icon: 'oleander', accentColor: 0xFFE17B8D,
    description: 'A drought-tolerant flowering shrub for sunny landscapes. Keep it away from children and pets because it is poisonous if eaten.', temperature: '18-35 C', exposure: 'Full sun', rainfall: '400-1200 mm/year', humidity: '35-75%', watering: 'Low', soil: 'Sandy, well-drained', ph: '6-8', spacing: '1.5-3 m plant to plant', companions: <String>['Lavender', 'Rosemary', 'Aloe vera'], rotation: <String>['Organic mulch', 'Ground cover', 'Soil rest'], nutrients: <String>['Compost after pruning', 'Light balanced feed', 'Avoid excess water'],
  ),
  CropProfile(
    id: 'crossandra', name: 'Crossandra', scientificName: 'Crossandra infundibuliformis', category: 'Flowering shrub', icon: 'crossandra', accentColor: 0xFFE27C42,
    description: 'A warm-climate ornamental shrub with bright flowers that prefers humidity, filtered light, and moist soil.', temperature: '20-35 C', exposure: 'Bright light to partial shade', rainfall: '800-1800 mm/year', humidity: '60-90%', watering: 'Intermediate', soil: 'Rich, well-drained loam', ph: '5.5-7', spacing: '30-45 cm plant to plant', companions: <String>['Jasmine', 'Ferns', 'Marigold'], rotation: <String>['Compost cover', 'Legume cover', 'Ground cover'], nutrients: <String>['Compost regularly', 'Balanced feed during growth', 'Potassium during flowering'],
  ),
  CropProfile(
    id: 'balsam', name: 'Balsam', scientificName: 'Impatiens balsamina', category: 'Annual flower', icon: 'balsam', accentColor: 0xFFD95C87,
    description: 'A quick-growing annual flower that thrives in warm weather, morning sun, and evenly moist soil.', temperature: '18-32 C', exposure: 'Full sun to partial shade', rainfall: '600-1500 mm/year', humidity: '55-85%', watering: 'Intermediate', soil: 'Moist, fertile loam', ph: '6-7.5', spacing: '20-30 cm plant to plant', companions: <String>['Marigold', 'Basil', 'Cosmos'], rotation: <String>['Legume', 'Cereal', 'Cover crop'], nutrients: <String>['Compost before sowing', 'Light balanced feed', 'Avoid waterlogging'],
  ),
  CropProfile(
    id: 'calendula', name: 'Calendula', scientificName: 'Calendula officinalis', category: 'Annual flower', icon: 'calendula', accentColor: 0xFFE8A83C,
    description: 'A cool-season flower with bright blooms that grows well in sunny beds and moderate fertile soil.', temperature: '10-25 C', exposure: 'Full sun', rainfall: '400-800 mm/season', humidity: '40-70%', watering: 'Low', soil: 'Loamy, well-drained', ph: '6-7.5', spacing: '20-30 cm plant to plant', companions: <String>['Tomato', 'Bean', 'Carrot'], rotation: <String>['Legume', 'Cereal', 'Vegetable'], nutrients: <String>['Compost before planting', 'Avoid excess nitrogen', 'Deadhead for repeat blooms'],
  ),
  CropProfile(
    id: 'gladiolus', name: 'Gladiolus', scientificName: 'Gladiolus hybridus', category: 'Bulb flower', icon: 'gladiolus', accentColor: 0xFFE0759A,
    description: 'A tall spike flower that needs full sun, fertile soil, regular moisture, and support in windy locations.', temperature: '15-30 C', exposure: 'Full sun', rainfall: '600-1200 mm/year', humidity: '45-75%', watering: 'Intermediate', soil: 'Fertile, well-drained loam', ph: '6-7', spacing: '15 cm row / 10 cm plant', companions: <String>['Marigold', 'Basil', 'Alyssum'], rotation: <String>['Legume', 'Cereal', 'Green manure'], nutrients: <String>['Compost before planting', 'Phosphorus for corms', 'Potassium for strong flower spikes'],
  ),
  CropProfile(
    id: 'pansy', name: 'Pansy', scientificName: 'Viola x wittrockiana', category: 'Annual flower', icon: 'pansy', accentColor: 0xFF736BB6,
    description: 'A cool-season bedding flower that prefers mild temperatures, bright light, and well-drained potting soil.', temperature: '7-22 C', exposure: 'Full sun to partial shade', rainfall: '500-900 mm/season', humidity: '45-75%', watering: 'Intermediate', soil: 'Fertile, well-drained loam', ph: '5.5-6.5', spacing: '20-25 cm plant to plant', companions: <String>['Tulip', 'Alyssum', 'Calendula'], rotation: <String>['Legume', 'Leafy greens', 'Fresh potting mix'], nutrients: <String>['Regular light flower feed', 'Compost before planting', 'Remove faded flowers'],
  ),
  CropProfile(
    id: 'snapdragon', name: 'Snapdragon', scientificName: 'Antirrhinum majus', category: 'Annual flower', icon: 'snapdragon', accentColor: 0xFFD77B8C,
    description: 'A cool-season flower with tall colorful spikes that needs sunlight, fertile soil, and moderate watering.', temperature: '10-25 C', exposure: 'Full sun', rainfall: '450-900 mm/season', humidity: '40-70%', watering: 'Intermediate', soil: 'Loamy, well-drained', ph: '6-7.5', spacing: '20-30 cm plant to plant', companions: <String>['Pansy', 'Marigold', 'Alyssum'], rotation: <String>['Legume', 'Cereal', 'Cover crop'], nutrients: <String>['Compost before transplanting', 'Balanced feed during growth', 'Potassium before flowering'],
  ),
];
