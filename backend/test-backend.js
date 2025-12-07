const http = require('http');

console.log('🧪 Test du Backend Paymee\n');

// Test 1: Vérifier que le serveur est actif
console.log('1️⃣  Test de connexion au serveur...');
http.get('http://localhost:10000/', (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        console.log('   ✅ Serveur actif:', data);

        // Test 2: Créer un paiement de test
        console.log('\n2️⃣  Test de création de paiement...');

        const postData = JSON.stringify({
            amount: 10,
            orderId: 'TEST_' + Date.now(),
            email: 'test@edunet.com',
            firstName: 'Test',
            lastName: 'User',
            phone: '20123456'
        });

        const options = {
            hostname: 'localhost',
            port: 10000,
            path: '/createPayment',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': postData.length
            }
        };

        const req = http.request(options, (res) => {
            let responseData = '';
            res.on('data', chunk => responseData += chunk);
            res.on('end', () => {
                try {
                    const response = JSON.parse(responseData);
                    if (response.payment_url) {
                        console.log('   ✅ Paiement créé avec succès !');
                        console.log('   📍 URL de paiement:', response.payment_url);
                        console.log('   🔑 Token:', response.payment_token);
                        console.log('\n✅ Tous les tests réussis !');
                        console.log('\n💡 Le backend est prêt à être utilisé avec l'application Flutter.');
          } else {
                        console.log('   ❌ Erreur:', response.message || response.error);
                        console.log('   📝 Détails:', JSON.stringify(response, null, 2));
                        console.log('\n⚠️  Le backend fonctionne mais Paymee rejette les requêtes.');
                        console.log('   Vérifiez vos clés API dans backend/.env');
                    }
                } catch (e) {
                    console.log('   ❌ Erreur de parsing:', responseData);
                }
            });
        });

        req.on('error', (e) => {
            console.log('   ❌ Erreur:', e.message);
        });

        req.write(postData);
        req.end();
    });
}).on('error', (e) => {
    console.log('   ❌ Serveur non accessible:', e.message);
    console.log('\n💡 Assurez-vous que le backend est démarré avec: npm start');
});
