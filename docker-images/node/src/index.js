const Chance = require('chance');
const express = require('express');

const chance = new Chance();
const app = express();

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
  res.send(generateJSON());
});

app.listen(3000, () => {
  console.log('Accepting HTTP requests on port 3000');
});
