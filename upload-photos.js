/**
 * AOI-Foto Batch-Upload Script
 * Laedt alle Fotos aus FotosAOI/ in Supabase Storage
 * 
 * Usage: node upload-photos.js
 * 
 * Keine npm-Installation noetig — verwendet nur Node.js built-ins.
 */

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';

const SUPABASE_URL = 'https://yrephxnnkifrmwkqyzsa.supabase.co';
const SUPABASE_KEY = 'sb_publishable_nFZwPKhntA1nzMbcqWJfUg_I9JyM7WD';
const PHOTOS_DIR = '/Users/momu/html/aoi/KohYoung/FotosAOI';
const BUCKET = 'aoi-images';
const PREFIX = 'aoi-photos';

async function supabaseRequest(path, options = {}) {
    const url = `${SUPABASE_URL}${path}`;
    const res = await fetch(url, {
        ...options,
        headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`,
            ...options.headers
        }
    });
    return res;
}

async function listExisting() {
    const res = await supabaseRequest(`/storage/v1/object/list/${BUCKET}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prefix: PREFIX, limit: 1000 })
    });
    const data = await res.json();
    return new Set((data || []).map(f => f.name));
}

async function uploadFile(fileName, fileBuffer) {
    const storagePath = `${PREFIX}/${fileName}`;
    const res = await supabaseRequest(`/storage/v1/object/${BUCKET}/${storagePath}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'image/png',
            'x-upsert': 'false'
        },
        body: fileBuffer
    });
    if (!res.ok) {
        const err = await res.json();
        throw new Error(err.message || err.error || 'Upload failed');
    }
    return `${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${storagePath}`;
}

async function main() {
    console.log('=== AOI-Foto Batch-Upload ===\n');
    
    // 1. Dateien lesen (ohne "Kopie")
    const files = readdirSync(PHOTOS_DIR)
        .filter(f => {
            const isImage = f.endsWith('.png') || f.endsWith('.jpg') || f.endsWith('.jpeg');
            const isCopy = f.toLowerCase().includes('kopie') || f.toLowerCase().includes('copy');
            return isImage && !isCopy;
        })
        .sort();
    
    console.log(`Gefunden: ${files.length} Fotos (ohne Kopie-Dateien)`);
    
    // 2. Bereits hochgeladene pruefen
    const existing = await listExisting();
    const toUpload = files.filter(f => !existing.has(f));
    
    console.log(`Bereits im Storage: ${existing.size}`);
    console.log(`Noch hochzuladen: ${toUpload.length}\n`);
    
    if (toUpload.length === 0) {
        console.log('Alle Fotos sind bereits hochgeladen!');
        return;
    }
    
    // 3. Upload (einzeln, mit Pause)
    let uploaded = 0, failed = 0;
    
    for (const file of toUpload) {
        try {
            const buffer = readFileSync(join(PHOTOS_DIR, file));
            const url = await uploadFile(file, buffer);
            uploaded++;
            console.log(`  [${uploaded}/${toUpload.length}] OK: ${file}`);
            
            // Pause um Rate Limit zu vermeiden
            if (uploaded % 10 === 0) {
                process.stdout.write('  --- Pause (1s) ---\n');
                await new Promise(r => setTimeout(r, 1000));
            }
        } catch (err) {
            failed++;
            console.error(`  FEHLER: ${file} — ${err.message}`);
        }
    }
    
    console.log(`\n=== Ergebnis ===`);
    console.log(`Hochgeladen: ${uploaded}`);
    console.log(`Fehler: ${failed}`);
    console.log(`Gesamt: ${existing.size + uploaded} Fotos im Storage`);
    console.log(`\nStorage-Pfad: ${PREFIX}/`);
    console.log(`URL-Pattern: ${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${PREFIX}/{DATEINAME}`);
}

main().catch(err => {
    console.error('Fataler Fehler:', err);
    process.exit(1);
});
