cd assets/
npm run deploy
cd ../
MIX_ENV=prod mix phx.digest
git push heroku master