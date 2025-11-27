// src/components/admin/PaymentList.js
import { useEffect, useState } from "react";
import PaymentListViewModel from "../../viewmodels/admin/PaymentListViewModel";

export default function PaymentList() {
  const [vm, setVm] = useState(PaymentListViewModel);

  useEffect(() => {
    const loadPayments = async () => {
      await vm.fetchPayments();
      setVm({ ...vm });
    };
    loadPayments();
  }, []);

  if (vm.loading) return <p>Chargement des paiements...</p>;
  if (vm.error) return <p>Erreur: {vm.error}</p>;

  return (
    <div className="max-w-5xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Gestion des paiements</h1>
      <table className="w-full border-collapse">
        <thead>
          <tr className="bg-gray-100">
            <th className="p-3 border">Utilisateur</th>
            <th className="p-3 border">Montant</th>
            <th className="p-3 border">Date</th>
            <th className="p-3 border">Cours/Abonnement</th>
            <th className="p-3 border">Statut</th>
          </tr>
        </thead>
        <tbody>
          {vm.payments.map((payment) => (
            <tr key={payment.id} className="text-center border-b">
              <td className="p-3">{payment.userName}</td>
              <td className="p-3">{payment.amount} TND</td>
              <td className="p-3">
                {new Date(payment.date.seconds * 1000).toLocaleDateString()}
              </td>
              <td className="p-3">{payment.courseName}</td>
              <td
                className={`p-3 ${
                  payment.status === "Réussi"
                    ? "text-green-600"
                    : "text-red-600"
                }`}
              >
                {payment.status}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
