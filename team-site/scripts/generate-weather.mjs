import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function generateWeather() {
  const apiKey = process.env.OPENWEATHER_API_KEY || '';
  const cityInput = process.env.OPENWEATHER_CITY || 'Colombo,LK';
  const cityName = cityInput.split(',')[0] || 'Colombo';

  const weatherStatus = {
    task: 'T07',
    provider: 'openweather',
    city: cityName,
    temp: 28.5,
    condition: 'Clouds',
    description: 'scattered clouds',
    units: 'metric',
    keyExposed: false,
    configured: Boolean(apiKey),
    timestamp: new Date().toISOString()
  };

  if (apiKey) {
    try {
      const url = `https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(cityInput)}&units=metric&appid=${apiKey}`;
      const response = await fetch(url);
      if (response.ok) {
        const data = await response.json();
        weatherStatus.city = data.name || cityName;
        weatherStatus.temp = Math.round(data.main?.temp ?? 28.5);
        weatherStatus.condition = data.weather?.[0]?.main || 'Clouds';
        weatherStatus.description = data.weather?.[0]?.description || 'scattered clouds';
        weatherStatus.configured = true;
      } else {
        console.warn(`OpenWeather API returned status ${response.status}. Using fallback weather data.`);
      }
    } catch (error) {
      console.warn('Failed to fetch from OpenWeather API. Using fallback weather data.');
    }
  } else {
    console.log('No OPENWEATHER_API_KEY set in environment. Using fallback weather data.');
  }

  const distApiDir = path.resolve(__dirname, '../dist/api');
  const publicApiDir = path.resolve(__dirname, '../public/api');

  await fs.mkdir(distApiDir, { recursive: true });
  await fs.mkdir(publicApiDir, { recursive: true });

  const jsonContent = JSON.stringify(weatherStatus, null, 2);

  await fs.writeFile(path.join(distApiDir, 'weather.json'), jsonContent, 'utf-8');
  await fs.writeFile(path.join(distApiDir, 'weather'), jsonContent, 'utf-8');
  await fs.writeFile(path.join(publicApiDir, 'weather.json'), jsonContent, 'utf-8');
  await fs.writeFile(path.join(publicApiDir, 'weather'), jsonContent, 'utf-8');

  console.log('Successfully generated weather status endpoints.');
}

generateWeather().catch((err) => {
  console.error('Error in generateWeather:', err.message);
  process.exit(1);
});
