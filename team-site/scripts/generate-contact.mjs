import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function generateContactConfig() {
    const accessKey = process.env.WEB3FORMS_ACCESS_KEY || '';

    const contactConfig = {
        task: 'T10',
        provider: 'web3forms',
        configured: Boolean(accessKey),
        accessKey: accessKey || 'YOUR_ACCESS_KEY_HERE',
        timestamp: new Date().toISOString()
    };

    if (!accessKey) {
        console.log('No WEB3FORMS_ACCESS_KEY set in environment. Using fallback contact config.');
    }

    const distApiDir = path.resolve(__dirname, '../dist/api');
    const publicApiDir = path.resolve(__dirname, '../public/api');

    await fs.mkdir(distApiDir, { recursive: true });
    await fs.mkdir(publicApiDir, { recursive: true });

    const jsonContent = JSON.stringify(contactConfig, null, 2);

    await fs.writeFile(path.join(distApiDir, 'contact.json'), jsonContent, 'utf-8');
    await fs.writeFile(path.join(distApiDir, 'contact'), jsonContent, 'utf-8');
    await fs.writeFile(path.join(publicApiDir, 'contact.json'), jsonContent, 'utf-8');
    await fs.writeFile(path.join(publicApiDir, 'contact'), jsonContent, 'utf-8');

    console.log('Successfully generated Web3Forms contact configuration.');
}

generateContactConfig().catch((err) => {
    console.error('Error in generateContactConfig:', err.message);
    process.exit(1);
});
