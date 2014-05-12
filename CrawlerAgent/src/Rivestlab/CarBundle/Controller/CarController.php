<?php

namespace Rivestlab\CarBundle\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;

use Rivestlab\CarBundle\Entity\Car;
use Rivestlab\CarBundle\Form\CarType;

/**
 * Car controller.
 *
 */
class CarController extends Controller
{
    /**
     * Lists all Car entities.
     *
     */
    public function indexAction()
    {
        $em = $this->getDoctrine()->getManager();

        $entities = $em->getRepository('RivestlabCarBundle:Car')->findAll();

        return $this->render('RivestlabCarBundle:Car:index.html.twig', array(
            'entities' => $entities,
        ));
    }

    /**
     * Creates a new Car entity.
     *
     */
    public function createAction(Request $request)
    {
        $entity  = new Car();
        $form = $this->createForm(new CarType(), $entity);
        $form->bind($request);

        if ($form->isValid()) {
            $em = $this->getDoctrine()->getManager();
            $em->persist($entity);
            $em->flush();

            return $this->redirect($this->generateUrl('carcrud_show', array('id' => $entity->getId())));
        }

        return $this->render('RivestlabCarBundle:Car:new.html.twig', array(
            'entity' => $entity,
            'form'   => $form->createView(),
        ));
    }

    /**
     * Displays a form to create a new Car entity.
     *
     */
    public function newAction()
    {
        $entity = new Car();
        $form   = $this->createForm(new CarType(), $entity);

        return $this->render('RivestlabCarBundle:Car:new.html.twig', array(
            'entity' => $entity,
            'form'   => $form->createView(),
        ));
    }

    /**
     * Finds and displays a Car entity.
     *
     */
    public function showAction($id)
    {
        $em = $this->getDoctrine()->getManager();

        $entity = $em->getRepository('RivestlabCarBundle:Car')->find($id);

        if (!$entity) {
            throw $this->createNotFoundException('Unable to find Car entity.');
        }

        $deleteForm = $this->createDeleteForm($id);

        return $this->render('RivestlabCarBundle:Car:show.html.twig', array(
            'entity'      => $entity,
            'delete_form' => $deleteForm->createView(),        ));
    }

    /**
     * Displays a form to edit an existing Car entity.
     *
     */
    public function editAction($id)
    {
        $em = $this->getDoctrine()->getManager();

        $entity = $em->getRepository('RivestlabCarBundle:Car')->find($id);

        if (!$entity) {
            throw $this->createNotFoundException('Unable to find Car entity.');
        }

        $editForm = $this->createForm(new CarType(), $entity);
        $deleteForm = $this->createDeleteForm($id);

        return $this->render('RivestlabCarBundle:Car:edit.html.twig', array(
            'entity'      => $entity,
            'edit_form'   => $editForm->createView(),
            'delete_form' => $deleteForm->createView(),
        ));
    }

    /**
     * Edits an existing Car entity.
     *
     */
    public function updateAction(Request $request, $id)
    {
        $em = $this->getDoctrine()->getManager();

        $entity = $em->getRepository('RivestlabCarBundle:Car')->find($id);

        if (!$entity) {
            throw $this->createNotFoundException('Unable to find Car entity.');
        }

        $deleteForm = $this->createDeleteForm($id);
        $editForm = $this->createForm(new CarType(), $entity);
        $editForm->bind($request);

        if ($editForm->isValid()) {
            $em->persist($entity);
            $em->flush();

            return $this->redirect($this->generateUrl('carcrud_edit', array('id' => $id)));
        }

        return $this->render('RivestlabCarBundle:Car:edit.html.twig', array(
            'entity'      => $entity,
            'edit_form'   => $editForm->createView(),
            'delete_form' => $deleteForm->createView(),
        ));
    }

    /**
     * Deletes a Car entity.
     *
     */
    public function deleteAction(Request $request, $id)
    {
        $form = $this->createDeleteForm($id);
        $form->bind($request);

        if ($form->isValid()) {
            $em = $this->getDoctrine()->getManager();
            $entity = $em->getRepository('RivestlabCarBundle:Car')->find($id);

            if (!$entity) {
                throw $this->createNotFoundException('Unable to find Car entity.');
            }

            $em->remove($entity);
            $em->flush();
        }

        return $this->redirect($this->generateUrl('carcrud'));
    }

    /**
     * Creates a form to delete a Car entity by id.
     *
     * @param mixed $id The entity id
     *
     * @return Symfony\Component\Form\Form The form
     */
    private function createDeleteForm($id)
    {
        return $this->createFormBuilder(array('id' => $id))
            ->add('id', 'hidden')
            ->getForm()
        ;
    }
}
