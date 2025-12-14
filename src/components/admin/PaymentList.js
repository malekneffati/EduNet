// src/components/admin/PaymentList.js
import { useEffect, useState } from "react";
import PaymentListViewModel from "../../viewmodels/admin/PaymentListViewModel";

export default function PaymentList() {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    const loadPayments = async () => {
      try {
        await PaymentListViewModel.fetchPayments();
        setPayments(PaymentListViewModel.payments);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };
    loadPayments();
  }, []);

  const filteredPayments = payments.filter((payment) =>
    Object.values(payment).some(
      (val) =>
        typeof val === "string" &&
        val.toLowerCase().includes(searchTerm.toLowerCase())
    )
  );

  if (loading) return <p>Chargement des paiements...</p>;
  if (error) return <p>Erreur: {error}</p>;

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="mb-6 relative">
        <input
          type="text"
          placeholder="Rechercher par utilisateur, cours ou transaction..."
          className="w-full pl-10 pr-4 py-2 border rounded-lg text-gray-700 focus:outline-none focus:border-blue-500"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
        <svg
          className="w-5 h-5 text-gray-400 absolute left-3 top-3"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="2"
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
          />
        </svg>
      </div>

      <table className="w-full text-left">
        <thead>
          <tr className="border-b">
            <th className="pb-3 text-gray-600 font-semibold">Utilisateur</th>
            <th className="pb-3 text-gray-600 font-semibold">Cours</th>
            <th className="pb-3 text-gray-600 font-semibold">Montant</th>
            <th className="pb-3 text-gray-600 font-semibold">Date</th>
          </tr>
        </thead>
        <tbody>
          {filteredPayments.map((payment) => (
            <tr
              key={payment.id}
              className="border-b last:border-b-0 hover:bg-gray-50"
            >
              <td className="py-4 text-gray-800">{payment.userName}</td>
              <td className="py-4 text-gray-600">{payment.courseTitle}</td>
              <td className="py-4 text-gray-600">{payment.montant} TND</td>
              <td className="py-4 text-gray-600">
                {new Date(payment.date.seconds * 1000).toLocaleDateString(
                  "fr-FR",
                  {
                    day: "numeric",
                    month: "long",
                    year: "numeric",
                  }
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
