// Les catalogues de l'app iOS et du simulateur web doivent être identiques, octet pour octet.
// node scripts/check-parity.mjs — code de sortie 1 au premier écart.
import { createHash } from 'node:crypto';
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const IOS = 'AevumApp/Resources/Data';
const WEB = 'web_preview/data';
const sha = (file) => createHash('sha256').update(readFileSync(file)).digest('hex');

const files = readdirSync(IOS).filter((f) => f.endsWith('.json')).sort();
let failures = 0;
for (const file of files) {
  const web = join(WEB, file);
  if (!existsSync(web)) {
    console.log(`✗ ${file}: missing in ${WEB}`);
    failures++;
  } else if (sha(join(IOS, file)) !== sha(web)) {
    console.log(`✗ ${file}: iOS and web copies differ`);
    failures++;
  } else {
    console.log(`✓ ${file}`);
  }
}
console.log(`${files.length - failures}/${files.length} catalogues identical`);
if (files.length === 0 || failures > 0) process.exitCode = 1;
