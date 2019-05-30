const Chance = require('chance');
const express = require('express');
const fs = require('fs');

const chance = new Chance();
const app = express();


const docker_name = fs.readFileSync('/etc/hostname', 'utf8');
let number = 1;

function generateJSON() {
  const size = chance.integer({ min: 1, max: 10 });

  const companies = [];
  for (let i = 0; i < size; i += 1) {
    companies.push({
      name: chance.company(),
      street: `${chance.street()} ${chance.integer({ min: 1, max: 50 })}`,
      city: chance.city(),
      country: chance.country(),
    });
  }

  return companies;
}

app.get('/', (req, res) => {
  console.log(`${docker_name} received a request #${number}`);
  number += 1;
  res.send(generateJSON());
});

app.listen(3000, () => {
  console.log('Accepting HTTP requests on port 3000');
});
