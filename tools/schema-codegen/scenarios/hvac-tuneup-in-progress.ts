import { scenario, user, customer, job } from '../src/seeding/factories';

const sarah = user({
  id: 'user-sarah',
  data: {
    display_name: 'Sarah Chen',
    email: 'sarah@coolhvac.com',
    role: 'dispatcher'
  }
});

const bob = user({
  id: 'user-bob',
  data: {
    display_name: 'Bob Wilson',
    email: 'bob@coolhvac.com',
    role: 'tech'
  }
});

const john = customer({
  id: 'customer-john',
  data: {
    name: 'John Smith',
    contact: { email: 'john@example.com', phone: '555-1234' },
    address: { street: '123 Main St', city: 'Austin', state: 'TX', zip_code: '78701' }
  }
});

export default scenario({
  name: 'HVAC Tuneup - In Progress',
  description: 'Tech Bob is on-site performing an AC tuneup for John Smith',
  tenant: { name: 'Cool HVAC LLC', plan: 'pro' },

  records: [
    sarah,
    bob,
    john,

    job({
      id: 'job-1024',
      data: {
        job_number: 'J-1024',
        customer_id: john.id,
        job_address: { street: '123 Main St', city: 'Austin', state: 'TX', zip_code: '78701' },
        job_description: 'Annual AC tuneup',
        assigned_tech_id: bob.id,
        status_note: 'Tech on site, inspecting unit'
      }
    })
  ],

  testScript: [
    { device: 'iPad', actor: 'Sarah', action: 'Open Jobs list, find J-1024, verify status "In Progress"' },
    { device: 'iPhone', actor: 'Bob', action: 'Open job J-1024, mark as "Completed"' },
    { device: 'iPad', actor: 'Sarah', action: 'Verify status changed to "Completed" in real-time' }
  ]
});